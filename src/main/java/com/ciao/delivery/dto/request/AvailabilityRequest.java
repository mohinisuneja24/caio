package com.ciao.delivery.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class AvailabilityRequest {

    @NotNull(message = "Available-from time is required")
    private LocalTime availableFrom;

    @NotNull(message = "Available-to time is required")
    private LocalTime availableTo;
}
