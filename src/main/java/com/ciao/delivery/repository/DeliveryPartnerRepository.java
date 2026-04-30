package com.ciao.delivery.repository;

import com.ciao.delivery.entity.DeliveryPartner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryPartnerRepository extends JpaRepository<DeliveryPartner, Long> {

    Optional<DeliveryPartner> findByUserId(Long userId);

    boolean existsByUserId(Long userId);

    /**
     * Finds all delivery partners who are currently on duty and within their declared time window.
     * This is the core query that enforces the student-hours constraint.
     */
    @Query("""
            SELECT dp FROM DeliveryPartner dp
            WHERE dp.onDuty = true
              AND dp.availableFrom <= :now
              AND dp.availableTo >= :now
            """)
    List<DeliveryPartner> findAllAvailableAt(@Param("now") LocalTime now);
}
