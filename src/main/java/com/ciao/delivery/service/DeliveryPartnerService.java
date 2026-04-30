package com.ciao.delivery.service;

import com.ciao.delivery.dto.request.AvailabilityRequest;
import com.ciao.delivery.dto.response.DeliveryPartnerResponse;
import com.ciao.delivery.entity.DeliveryPartner;
import com.ciao.delivery.entity.User;
import com.ciao.delivery.enums.Role;
import com.ciao.delivery.exception.BusinessException;
import com.ciao.delivery.exception.ResourceNotFoundException;
import com.ciao.delivery.exception.UnauthorizedException;
import com.ciao.delivery.repository.DeliveryPartnerRepository;
import com.ciao.delivery.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DeliveryPartnerService {

    private final DeliveryPartnerRepository deliveryPartnerRepository;
    private final SecurityUtils securityUtils;

    @Transactional
    public DeliveryPartnerResponse registerAsDeliveryPartner(AvailabilityRequest request) {
        User currentUser = securityUtils.getCurrentUser();

        if (currentUser.getRole() != Role.DELIVERY) {
            throw new UnauthorizedException("Only users with role DELIVERY can register as delivery partners");
        }
        if (deliveryPartnerRepository.existsByUserId(currentUser.getId())) {
            throw new BusinessException("You are already registered as a delivery partner");
        }

        validateTimeWindow(request.getAvailableFrom(), request.getAvailableTo());

        DeliveryPartner partner = DeliveryPartner.builder()
                .user(currentUser)
                .availableFrom(request.getAvailableFrom())
                .availableTo(request.getAvailableTo())
                .build();

        return DeliveryPartnerResponse.from(deliveryPartnerRepository.save(partner));
    }

    @Transactional
    public DeliveryPartnerResponse updateAvailability(AvailabilityRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        DeliveryPartner partner = getByUserId(currentUser.getId());

        validateTimeWindow(request.getAvailableFrom(), request.getAvailableTo());

        partner.setAvailableFrom(request.getAvailableFrom());
        partner.setAvailableTo(request.getAvailableTo());

        return DeliveryPartnerResponse.from(deliveryPartnerRepository.save(partner));
    }

    @Transactional
    public DeliveryPartnerResponse toggleDutyStatus() {
        User currentUser = securityUtils.getCurrentUser();
        DeliveryPartner partner = getByUserId(currentUser.getId());
        partner.setOnDuty(!partner.isOnDuty());
        return DeliveryPartnerResponse.from(deliveryPartnerRepository.save(partner));
    }

    @Transactional(readOnly = true)
    public List<DeliveryPartnerResponse> getAvailablePartners() {
        return deliveryPartnerRepository.findAllAvailableAt(LocalTime.now())
                .stream()
                .map(DeliveryPartnerResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public DeliveryPartnerResponse getMyProfile() {
        User currentUser = securityUtils.getCurrentUser();
        return DeliveryPartnerResponse.from(getByUserId(currentUser.getId()));
    }

    public DeliveryPartner findFirstAvailableNow() {
        return deliveryPartnerRepository.findAllAvailableAt(LocalTime.now())
                .stream()
                .findFirst()
                .orElse(null);
    }

    public DeliveryPartner findById(Long id) {
        return deliveryPartnerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery partner", id));
    }

    private DeliveryPartner getByUserId(Long userId) {
        return deliveryPartnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery partner profile not found. Please register first."));
    }

    private void validateTimeWindow(LocalTime from, LocalTime to) {
        if (!from.isBefore(to)) {
            throw new BusinessException("available_from must be earlier than available_to");
        }
    }
}
