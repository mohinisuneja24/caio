package com.ciao.delivery.dto.response;

import com.ciao.delivery.enums.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String token;
    private String name;
    private String phone;
    private Role role;
}
