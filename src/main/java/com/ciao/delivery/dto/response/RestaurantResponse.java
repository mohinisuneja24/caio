package com.ciao.delivery.dto.response;

import com.ciao.delivery.entity.Restaurant;
import lombok.Builder;
import lombok.Data;

import java.time.LocalTime;

@Data
@Builder
public class RestaurantResponse {
    private Long id;
    private String name;
    private String location;
    private LocalTime openTime;
    private LocalTime closeTime;
    private boolean open;

    public static RestaurantResponse from(Restaurant restaurant) {
        return RestaurantResponse.builder()
                .id(restaurant.getId())
                .name(restaurant.getName())
                .location(restaurant.getLocation())
                .openTime(restaurant.getOpenTime())
                .closeTime(restaurant.getCloseTime())
                .open(restaurant.isCurrentlyOpen())
                .build();
    }
}
