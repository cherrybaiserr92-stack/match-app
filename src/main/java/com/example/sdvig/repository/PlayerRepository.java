package com.example.sdvig.repository;

import com.example.sdvig.model.PlayerProfile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlayerRepository extends JpaRepository<PlayerProfile, String> {
}
