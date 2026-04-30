package com.ciao.delivery.dto.response;

import com.ciao.delivery.entity.Order;
import com.ciao.delivery.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class OrderResponse {
    private Long id;
    private Long userId;
    private Long restaurantId;
    private String restaurantName;
    private Long deliveryPartnerId;
    private String deliveryPartnerName;
    private List<String> itemNames;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private String deliveryAddress;
    private LocalDateTime createdAt;

    public static OrderResponse from(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .userId(order.getUser().getId())
                .restaurantId(order.getRestaurant().getId())
                .restaurantName(order.getRestaurant().getName())
                .deliveryPartnerId(order.getDeliveryPartner() != null ? order.getDeliveryPartner().getId() : null)
                .deliveryPartnerName(order.getDeliveryPartner() != null ? order.getDeliveryPartner().getUser().getName() : null)
                .itemNames(order.getItems().stream().map(i -> i.getName()).toList())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus())
                .deliveryAddress(order.getDeliveryAddress())
                .createdAt(order.getCreatedAt())
                .build();
    }
}
