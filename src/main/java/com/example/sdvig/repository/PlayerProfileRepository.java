package com.example.sdvig.repository;

import com.example.sdvig.model.PlayerProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PlayerProfileRepository extends JpaRepository<PlayerProfile, Long> {
    Optional<PlayerProfile> findByProviderId(String providerId);
}
