package com.ciao.delivery.controller;

import com.ciao.delivery.dto.request.OrderRequest;
import com.ciao.delivery.dto.response.ApiResponse;
import com.ciao.delivery.dto.response.OrderResponse;
import com.ciao.delivery.enums.OrderStatus;
import com.ciao.delivery.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<OrderResponse>> placeOrder(@Valid @RequestBody OrderRequest request) {
        OrderResponse response = orderService.placeOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Order placed successfully", response));
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getMyOrders() {
        return ResponseEntity.ok(ApiResponse.ok("Orders fetched", orderService.getMyOrders()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrderById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order fetched", orderService.getOrderById(id)));
    }

    @GetMapping("/restaurant/{restaurantId}")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getRestaurantOrders(@PathVariable Long restaurantId) {
        return ResponseEntity.ok(ApiResponse.ok("Orders fetched", orderService.getOrdersForMyRestaurant(restaurantId)));
    }

    @PatchMapping("/{id}/accept")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<OrderResponse>> acceptOrder(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order accepted and delivery partner assigned", orderService.acceptOrder(id)));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<OrderResponse>> updateStatus(
            @PathVariable Long id,
            @RequestParam OrderStatus status) {
        return ResponseEntity.ok(ApiResponse.ok("Order status updated", orderService.updateOrderStatus(id, status)));
    }

    @PatchMapping("/{id}/cancel")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order cancelled", orderService.cancelOrder(id)));
    }
}
