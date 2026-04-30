package com.ciao.delivery.controller;

import com.ciao.delivery.dto.request.AvailabilityRequest;
import com.ciao.delivery.dto.response.ApiResponse;
import com.ciao.delivery.dto.response.DeliveryPartnerResponse;
import com.ciao.delivery.service.DeliveryPartnerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/delivery-partners")
@RequiredArgsConstructor
public class DeliveryPartnerController {

    private final DeliveryPartnerService deliveryPartnerService;

    @PostMapping("/register")
    @PreAuthorize("hasRole('DELIVERY')")
    public ResponseEntity<ApiResponse<DeliveryPartnerResponse>> register(
            @Valid @RequestBody AvailabilityRequest request) {
        DeliveryPartnerResponse response = deliveryPartnerService.registerAsDeliveryPartner(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Registered as delivery partner", response));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('DELIVERY')")
    public ResponseEntity<ApiResponse<DeliveryPartnerResponse>> getMyProfile() {
        return ResponseEntity.ok(ApiResponse.ok("Profile fetched", deliveryPartnerService.getMyProfile()));
    }

    @PutMapping("/availability")
    @PreAuthorize("hasRole('DELIVERY')")
    public ResponseEntity<ApiResponse<DeliveryPartnerResponse>> updateAvailability(
            @Valid @RequestBody AvailabilityRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Availability updated", deliveryPartnerService.updateAvailability(request)));
    }

    @PatchMapping("/duty")
    @PreAuthorize("hasRole('DELIVERY')")
    public ResponseEntity<ApiResponse<DeliveryPartnerResponse>> toggleDuty() {
        return ResponseEntity.ok(ApiResponse.ok("Duty status toggled", deliveryPartnerService.toggleDutyStatus()));
    }

    @GetMapping("/available")
    @PreAuthorize("hasAnyRole('RESTAURANT', 'DELIVERY')")
    public ResponseEntity<ApiResponse<List<DeliveryPartnerResponse>>> getAvailablePartners() {
        return ResponseEntity.ok(ApiResponse.ok("Available partners fetched", deliveryPartnerService.getAvailablePartners()));
    }
}
