package com.ciao.delivery.dto.response;

import com.ciao.delivery.entity.DeliveryPartner;
import lombok.Builder;
import lombok.Data;

import java.time.LocalTime;

@Data
@Builder
public class DeliveryPartnerResponse {
    private Long id;
    private Long userId;
    private String name;
    private LocalTime availableFrom;
    private LocalTime availableTo;
    private boolean onDuty;
    private boolean availableNow;

    public static DeliveryPartnerResponse from(DeliveryPartner dp) {
        return DeliveryPartnerResponse.builder()
                .id(dp.getId())
                .userId(dp.getUser().getId())
                .name(dp.getUser().getName())
                .availableFrom(dp.getAvailableFrom())
                .availableTo(dp.getAvailableTo())
                .onDuty(dp.isOnDuty())
                .availableNow(dp.isAvailableNow())
                .build();
    }
}
