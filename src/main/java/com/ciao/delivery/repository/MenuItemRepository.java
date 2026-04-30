package com.ciao.delivery.repository;

import com.ciao.delivery.entity.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, Long> {

    List<MenuItem> findAllByRestaurantIdAndAvailableTrue(Long restaurantId);

    List<MenuItem> findAllByRestaurantId(Long restaurantId);
}
