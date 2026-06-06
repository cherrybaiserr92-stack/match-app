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

    private int energy      = 100;
    private int credits     = 150;
    private int rank        = 1;
    private int xp          = 0;

    // Skills
    private int skill1      = 1; // Проницательность → XP boost
    private int skill2      = 1; // Технологии → energy reduction

    // Game levels
    private int detectiveLvl  = 1;
    private int doctorLvl     = 1;
    private int universalLvl  = 1;

    // Stats
    private int totalCases    = 0;
    private int streak        = 0;

    // Daily bonus: stored as "YYYY-MM-DD"
    @Column(name = "last_daily_bonus")
    private String lastDailyBonus = "";

    public PlayerProfile() {}

    // ── Getters / Setters ─────────────────────

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

    public int getDetectiveLvl() { return detectiveLvl; }
    public void setDetectiveLvl(int detectiveLvl) { this.detectiveLvl = detectiveLvl; }

    public int getDoctorLvl() { return doctorLvl; }
    public void setDoctorLvl(int doctorLvl) { this.doctorLvl = doctorLvl; }

    public int getUniversalLvl() { return universalLvl; }
    public void setUniversalLvl(int universalLvl) { this.universalLvl = universalLvl; }

    public int getTotalCases() { return totalCases; }
    public void setTotalCases(int totalCases) { this.totalCases = totalCases; }

    public int getStreak() { return streak; }
    public void setStreak(int streak) { this.streak = streak; }

    public String getLastDailyBonus() { return lastDailyBonus; }
    public void setLastDailyBonus(String lastDailyBonus) { this.lastDailyBonus = lastDailyBonus; }

    // Legacy field kept for Hibernate compatibility
    private int currentGameLevel = 1;
    public int getCurrentGameLevel() { return currentGameLevel; }
    public void setCurrentGameLevel(int currentGameLevel) { this.currentGameLevel = currentGameLevel; }
}

