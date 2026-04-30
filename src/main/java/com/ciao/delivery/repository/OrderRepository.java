package com.ciao.delivery.repository;

import com.ciao.delivery.entity.Order;
import com.ciao.delivery.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findAllByUserId(Long userId);

    List<Order> findAllByRestaurantId(Long restaurantId);

    List<Order> findAllByDeliveryPartnerId(Long deliveryPartnerId);

    List<Order> findAllByRestaurantIdAndStatus(Long restaurantId, OrderStatus status);
}
