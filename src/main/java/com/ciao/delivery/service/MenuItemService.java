package com.ciao.delivery.service;

import com.ciao.delivery.dto.request.MenuItemRequest;
import com.ciao.delivery.dto.response.MenuItemResponse;
import com.ciao.delivery.entity.MenuItem;
import com.ciao.delivery.entity.Restaurant;
import com.ciao.delivery.entity.User;
import com.ciao.delivery.exception.ResourceNotFoundException;
import com.ciao.delivery.exception.UnauthorizedException;
import com.ciao.delivery.repository.MenuItemRepository;
import com.ciao.delivery.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MenuItemService {

    private final MenuItemRepository menuItemRepository;
    private final RestaurantService restaurantService;
    private final SecurityUtils securityUtils;

    @Transactional
    public MenuItemResponse addMenuItem(Long restaurantId, MenuItemRequest request) {
        Restaurant restaurant = restaurantService.findById(restaurantId);
        assertOwnership(restaurant);

        MenuItem item = MenuItem.builder()
                .restaurant(restaurant)
                .name(request.getName())
                .description(request.getDescription())
                .price(request.getPrice())
                .build();

        return MenuItemResponse.from(menuItemRepository.save(item));
    }

    @Transactional(readOnly = true)
    public List<MenuItemResponse> getMenuByRestaurant(Long restaurantId) {
        restaurantService.findById(restaurantId);
        return menuItemRepository.findAllByRestaurantIdAndAvailableTrue(restaurantId)
                .stream()
                .map(MenuItemResponse::from)
                .toList();
    }

    @Transactional
    public MenuItemResponse updateMenuItem(Long itemId, MenuItemRequest request) {
        MenuItem item = findById(itemId);
        assertOwnership(item.getRestaurant());

        item.setName(request.getName());
        item.setDescription(request.getDescription());
        item.setPrice(request.getPrice());

        return MenuItemResponse.from(menuItemRepository.save(item));
    }

    @Transactional
    public void toggleAvailability(Long itemId) {
        MenuItem item = findById(itemId);
        assertOwnership(item.getRestaurant());
        item.setAvailable(!item.isAvailable());
        menuItemRepository.save(item);
    }

    public MenuItem findById(Long id) {
        return menuItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Menu item", id));
    }

    private void assertOwnership(Restaurant restaurant) {
        User currentUser = securityUtils.getCurrentUser();
        if (!restaurant.getOwner().getId().equals(currentUser.getId())) {
            throw new UnauthorizedException("You do not own this restaurant");
        }
    }
}
