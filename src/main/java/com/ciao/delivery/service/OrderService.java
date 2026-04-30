package com.ciao.delivery.service;

import com.ciao.delivery.dto.request.OrderRequest;
import com.ciao.delivery.dto.response.OrderResponse;
import com.ciao.delivery.entity.DeliveryPartner;
import com.ciao.delivery.entity.MenuItem;
import com.ciao.delivery.entity.Order;
import com.ciao.delivery.entity.Restaurant;
import com.ciao.delivery.entity.User;
import com.ciao.delivery.enums.OrderStatus;
import com.ciao.delivery.enums.Role;
import com.ciao.delivery.exception.BusinessException;
import com.ciao.delivery.exception.ResourceNotFoundException;
import com.ciao.delivery.exception.UnauthorizedException;
import com.ciao.delivery.repository.OrderRepository;
import com.ciao.delivery.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final RestaurantService restaurantService;
    private final MenuItemService menuItemService;
    private final DeliveryPartnerService deliveryPartnerService;
    private final SecurityUtils securityUtils;

    @Transactional
    public OrderResponse placeOrder(OrderRequest request) {
        User currentUser = securityUtils.getCurrentUser();

        Restaurant restaurant = restaurantService.findById(request.getRestaurantId());

        if (!restaurant.isCurrentlyOpen()) {
            throw new BusinessException("Restaurant is currently closed. Please try again during open hours.");
        }

        List<MenuItem> items = request.getMenuItemIds().stream()
                .map(id -> {
                    MenuItem item = menuItemService.findById(id);
                    if (!item.getRestaurant().getId().equals(restaurant.getId())) {
                        throw new BusinessException("Menu item " + id + " does not belong to this restaurant");
                    }
                    if (!item.isAvailable()) {
                        throw new BusinessException("Menu item '" + item.getName() + "' is currently unavailable");
                    }
                    return item;
                })
                .toList();

        BigDecimal total = items.stream()
                .map(MenuItem::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Order order = Order.builder()
                .user(currentUser)
                .restaurant(restaurant)
                .items(items)
                .totalAmount(total)
                .deliveryAddress(request.getDeliveryAddress())
                .status(OrderStatus.PLACED)
                .build();

        Order saved = orderRepository.save(order);
        log.info("Order {} placed by user {} at restaurant {}", saved.getId(), currentUser.getId(), restaurant.getId());

        return OrderResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> getMyOrders() {
        User currentUser = securityUtils.getCurrentUser();
        return orderRepository.findAllByUserId(currentUser.getId())
                .stream()
                .map(OrderResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrderById(Long id) {
        Order order = findById(id);
        User currentUser = securityUtils.getCurrentUser();
        assertOrderAccess(order, currentUser);
        return OrderResponse.from(order);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> getOrdersForMyRestaurant(Long restaurantId) {
        User currentUser = securityUtils.getCurrentUser();
        Restaurant restaurant = restaurantService.findById(restaurantId);
        if (!restaurant.getOwner().getId().equals(currentUser.getId())) {
            throw new UnauthorizedException("You do not own this restaurant");
        }
        return orderRepository.findAllByRestaurantId(restaurantId)
                .stream()
                .map(OrderResponse::from)
                .toList();
    }

    /**
     * Restaurant owner accepts an order → triggers automatic assignment of an available delivery partner.
     */
    @Transactional
    public OrderResponse acceptOrder(Long orderId) {
        Order order = findById(orderId);
        User currentUser = securityUtils.getCurrentUser();

        if (!order.getRestaurant().getOwner().getId().equals(currentUser.getId())) {
            throw new UnauthorizedException("Only the restaurant owner can accept this order");
        }
        if (order.getStatus() != OrderStatus.PLACED) {
            throw new BusinessException("Order can only be accepted when in PLACED status. Current: " + order.getStatus());
        }

        order.setStatus(OrderStatus.ACCEPTED);

        DeliveryPartner partner = deliveryPartnerService.findFirstAvailableNow();
        if (partner != null) {
            order.setDeliveryPartner(partner);
            log.info("Delivery partner {} assigned to order {}", partner.getId(), orderId);
        } else {
            log.warn("No delivery partner available at this time for order {}", orderId);
        }

        return OrderResponse.from(orderRepository.save(order));
    }

    /**
     * Advances the order through the delivery pipeline.
     * Delivery partner can mark OUT_FOR_DELIVERY → DELIVERED.
     * Restaurant owner can mark ACCEPTED → OUT_FOR_DELIVERY.
     */
    @Transactional
    public OrderResponse updateOrderStatus(Long orderId, OrderStatus newStatus) {
        Order order = findById(orderId);
        User currentUser = securityUtils.getCurrentUser();

        validateStatusTransition(order, newStatus, currentUser);
        order.setStatus(newStatus);

        log.info("Order {} status updated to {} by user {}", orderId, newStatus, currentUser.getId());
        return OrderResponse.from(orderRepository.save(order));
    }

    @Transactional
    public OrderResponse cancelOrder(Long orderId) {
        Order order = findById(orderId);
        User currentUser = securityUtils.getCurrentUser();

        if (!order.getUser().getId().equals(currentUser.getId())) {
            throw new UnauthorizedException("You can only cancel your own orders");
        }
        if (order.getStatus() == OrderStatus.OUT_FOR_DELIVERY || order.getStatus() == OrderStatus.DELIVERED) {
            throw new BusinessException("Cannot cancel an order that is already out for delivery or delivered");
        }

        order.setStatus(OrderStatus.CANCELLED);
        return OrderResponse.from(orderRepository.save(order));
    }

    private void validateStatusTransition(Order order, OrderStatus newStatus, User currentUser) {
        Role role = currentUser.getRole();

        switch (newStatus) {
            case OUT_FOR_DELIVERY -> {
                if (role != Role.RESTAURANT && role != Role.DELIVERY) {
                    throw new UnauthorizedException("Only restaurant or delivery role can update to OUT_FOR_DELIVERY");
                }
                if (order.getStatus() != OrderStatus.ACCEPTED) {
                    throw new BusinessException("Order must be ACCEPTED before going OUT_FOR_DELIVERY");
                }
            }
            case DELIVERED -> {
                if (role != Role.DELIVERY) {
                    throw new UnauthorizedException("Only delivery partners can mark an order as DELIVERED");
                }
                if (order.getStatus() != OrderStatus.OUT_FOR_DELIVERY) {
                    throw new BusinessException("Order must be OUT_FOR_DELIVERY before it can be marked DELIVERED");
                }
                if (order.getDeliveryPartner() == null ||
                        !order.getDeliveryPartner().getUser().getId().equals(currentUser.getId())) {
                    throw new UnauthorizedException("Only the assigned delivery partner can mark this order as delivered");
                }
            }
            default -> throw new BusinessException("Invalid status transition to: " + newStatus);
        }
    }

    private void assertOrderAccess(Order order, User currentUser) {
        boolean isOwner = order.getUser().getId().equals(currentUser.getId());
        boolean isRestaurantOwner = order.getRestaurant().getOwner().getId().equals(currentUser.getId());
        boolean isAssignedPartner = order.getDeliveryPartner() != null &&
                order.getDeliveryPartner().getUser().getId().equals(currentUser.getId());

        if (!isOwner && !isRestaurantOwner && !isAssignedPartner) {
            throw new UnauthorizedException("You do not have access to this order");
        }
    }

    private Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order", id));
    }
}
