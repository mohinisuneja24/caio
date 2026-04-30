package com.ciao.delivery.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "delivery_partners")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryPartner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    /**
     * The time window within which a delivery partner (student) is allowed to accept deliveries.
     * This is the core USP of the platform — ensuring legal compliance for student workers.
     */
    @Column(nullable = false)
    private LocalTime availableFrom;

    @Column(nullable = false)
    private LocalTime availableTo;

    @Column(nullable = false)
    @Builder.Default
    private boolean onDuty = false;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    /**
     * Returns true if the partner is within their declared working window right now.
     */
    public boolean isAvailableNow() {
        LocalTime now = LocalTime.now();
        return onDuty && !now.isBefore(availableFrom) && !now.isAfter(availableTo);
    }
}
