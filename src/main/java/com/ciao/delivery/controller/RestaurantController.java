package com.ciao.delivery.controller;

import com.ciao.delivery.dto.request.RestaurantRequest;
import com.ciao.delivery.dto.response.ApiResponse;
import com.ciao.delivery.dto.response.RestaurantResponse;
import com.ciao.delivery.service.RestaurantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/restaurants")
@RequiredArgsConstructor
public class RestaurantController {

    private final RestaurantService restaurantService;

    @PostMapping
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<RestaurantResponse>> createRestaurant(
            @Valid @RequestBody RestaurantRequest request) {
        RestaurantResponse response = restaurantService.createRestaurant(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Restaurant created successfully", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<RestaurantResponse>>> getAllRestaurants() {
        List<RestaurantResponse> list = restaurantService.getAllActiveRestaurants();
        return ResponseEntity.ok(ApiResponse.ok("Restaurants fetched", list));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<List<RestaurantResponse>>> getMyRestaurants() {
        List<RestaurantResponse> list = restaurantService.getMyRestaurants();
        return ResponseEntity.ok(ApiResponse.ok("Your restaurants fetched", list));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<RestaurantResponse>> getRestaurant(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Restaurant fetched", restaurantService.getRestaurantById(id)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<RestaurantResponse>> updateRestaurant(
            @PathVariable Long id,
            @Valid @RequestBody RestaurantRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Restaurant updated", restaurantService.updateRestaurant(id, request)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<Void>> deactivateRestaurant(@PathVariable Long id) {
        restaurantService.deactivateRestaurant(id);
        return ResponseEntity.ok(ApiResponse.ok("Restaurant deactivated"));
    }
}
