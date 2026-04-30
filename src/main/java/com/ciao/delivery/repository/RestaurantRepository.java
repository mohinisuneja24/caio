package com.ciao.delivery.repository;

import com.ciao.delivery.entity.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {

    List<Restaurant> findAllByActiveTrue();

    List<Restaurant> findAllByOwnerIdAndActiveTrue(Long ownerId);
}
