package com.example.sdvig.model;

import jakarta.persistence.*;

@Entity
@Table(name = "player_profiles")
public class PlayerProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Универсальный ключ авторизации, например "tg:123456" или "google:user@mail.com"
    @Column(unique = true, nullable = false)
    private String providerId;

    private String username;
    private String firstName;
    
    private Integer level = 1;
    private Integer experience = 0;

    // Пустой конструктор нужен для Hibernate
    public PlayerProfile() {}

    // Геттеры и Сеттеры
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public Integer getLevel() { return level; }
    public void setLevel(Integer level) { this.level = level; }

    public Integer getExperience() { return experience; }
    public void setExperience(Integer experience) { this.experience = experience; }
}
