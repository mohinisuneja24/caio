package com.ciao.delivery.repository;

import com.ciao.delivery.entity.User;
import com.ciao.delivery.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByPhone(String phone);

    boolean existsByPhone(String phone);

    boolean existsByIdAndRole(Long id, Role role);
}
