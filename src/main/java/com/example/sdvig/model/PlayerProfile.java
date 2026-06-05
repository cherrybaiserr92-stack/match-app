package com.example.sdvig.model;

import jakarta.persistence.*;

@Entity
@Table(name = "player_profiles")
public class PlayerProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String providerId;

    private String username;
    private String firstName;
    private String archetype = "detective"; 
    
    private int energy = 100;
    private int credits = 150;
    private int rank = 1;
    private int xp = 0;
    
    // Навыки игрока
    private int skill1 = 1; // Проницательность (Увеличивает XP за квесты)
    private int skill2 = 1; // Технологии (Снижает затраты энергии)

    private int currentGameLevel = 1;

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

    public String getArchetype() { return archetype; }
    public void setArchetype(String archetype) { this.archetype = archetype; }

    public int getEnergy() { return energy; }
    public void setEnergy(int energy) { this.energy = energy; }

    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }

    public int getRank() { return rank; }
    public void setRank(int rank) { this.rank = rank; }

    public int getXp() { return xp; }
    public void setXp(int xp) { this.xp = xp; }

    public int getSkill1() { return skill1; }
    public void setSkill1(int skill1) { this.skill1 = skill1; }

    public int getSkill2() { return skill2; }
    public void setSkill2(int skill2) { this.skill2 = skill2; }

    public int getCurrentGameLevel() { return currentGameLevel; }
    public void setCurrentGameLevel(int currentGameLevel) { this.currentGameLevel = currentGameLevel; }
}
