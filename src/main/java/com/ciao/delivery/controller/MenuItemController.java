package com.ciao.delivery.controller;

import com.ciao.delivery.dto.request.MenuItemRequest;
import com.ciao.delivery.dto.response.ApiResponse;
import com.ciao.delivery.dto.response.MenuItemResponse;
import com.ciao.delivery.service.MenuItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
public class MenuItemController {

    private final MenuItemService menuItemService;

    @PostMapping
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<MenuItemResponse>> addItem(
            @PathVariable Long restaurantId,
            @Valid @RequestBody MenuItemRequest request) {
        MenuItemResponse response = menuItemService.addMenuItem(restaurantId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Menu item added", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MenuItemResponse>>> getMenu(@PathVariable Long restaurantId) {
        List<MenuItemResponse> menu = menuItemService.getMenuByRestaurant(restaurantId);
        return ResponseEntity.ok(ApiResponse.ok("Menu fetched", menu));
    }

    @PutMapping("/{itemId}")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<MenuItemResponse>> updateItem(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId,
            @Valid @RequestBody MenuItemRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Menu item updated", menuItemService.updateMenuItem(itemId, request)));
    }

    @PatchMapping("/{itemId}/toggle")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<Void>> toggleAvailability(
            @PathVariable Long restaurantId,
            @PathVariable Long itemId) {
        menuItemService.toggleAvailability(itemId);
        return ResponseEntity.ok(ApiResponse.ok("Menu item availability toggled"));
    }
}
