package com.ciao.delivery.security;

import com.ciao.delivery.entity.User;
import com.ciao.delivery.exception.UnauthorizedException;
import com.ciao.delivery.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final UserRepository userRepository;

    public User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof UserDetails ud) {
            return userRepository.findByPhone(ud.getUsername())
                    .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));
        }
        throw new UnauthorizedException("Not authenticated");
    }
}
