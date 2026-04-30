package com.ciao.delivery.service;

import com.ciao.delivery.dto.request.RestaurantRequest;
import com.ciao.delivery.dto.response.RestaurantResponse;
import com.ciao.delivery.entity.Restaurant;
import com.ciao.delivery.entity.User;
import com.ciao.delivery.enums.Role;
import com.ciao.delivery.exception.ResourceNotFoundException;
import com.ciao.delivery.exception.UnauthorizedException;
import com.ciao.delivery.repository.RestaurantRepository;
import com.ciao.delivery.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final SecurityUtils securityUtils;

    @Transactional
    public RestaurantResponse createRestaurant(RestaurantRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        if (currentUser.getRole() != Role.RESTAURANT) {
            throw new UnauthorizedException("Only restaurant owners can register restaurants");
        }

        Restaurant restaurant = Restaurant.builder()
                .name(request.getName())
                .location(request.getLocation())
                .openTime(request.getOpenTime())
                .closeTime(request.getCloseTime())
                .owner(currentUser)
                .build();

        return RestaurantResponse.from(restaurantRepository.save(restaurant));
    }

    @Transactional(readOnly = true)
    public List<RestaurantResponse> getAllActiveRestaurants() {
        return restaurantRepository.findAllByActiveTrue()
                .stream()
                .map(RestaurantResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RestaurantResponse> getMyRestaurants() {
        User currentUser = securityUtils.getCurrentUser();
        if (currentUser.getRole() != Role.RESTAURANT) {
            throw new UnauthorizedException("Only restaurant owners can list their restaurants");
        }
        return restaurantRepository.findAllByOwnerIdAndActiveTrue(currentUser.getId())
                .stream()
                .map(RestaurantResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public RestaurantResponse getRestaurantById(Long id) {
        return RestaurantResponse.from(findById(id));
    }

    @Transactional
    public RestaurantResponse updateRestaurant(Long id, RestaurantRequest request) {
        Restaurant restaurant = findById(id);
        assertOwnership(restaurant);

        restaurant.setName(request.getName());
        restaurant.setLocation(request.getLocation());
        restaurant.setOpenTime(request.getOpenTime());
        restaurant.setCloseTime(request.getCloseTime());

        return RestaurantResponse.from(restaurantRepository.save(restaurant));
    }

    @Transactional
    public void deactivateRestaurant(Long id) {
        Restaurant restaurant = findById(id);
        assertOwnership(restaurant);
        restaurant.setActive(false);
        restaurantRepository.save(restaurant);
    }

    public Restaurant findById(Long id) {
        return restaurantRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Restaurant", id));
    }

    private void assertOwnership(Restaurant restaurant) {
        User currentUser = securityUtils.getCurrentUser();
        if (!restaurant.getOwner().getId().equals(currentUser.getId())) {
            throw new UnauthorizedException("You do not own this restaurant");
        }
    }
}
