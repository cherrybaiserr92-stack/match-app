package com.example.sdvig.model;

import jakarta.persistence.*;

@Entity
@Table(name = "players")
public class PlayerProfile {

    @Id
    @Column(length = 64)
    private String id;            // tg:<telegram_id>  или  guest:<uuid>

    private String firstName;
    private String username;

    private int level = 1;
    private int xp = 0;
    private int energy = 5;
    private int maxEnergy = 5;
    private int credits = 0;

    private int casesSolved = 0;
    private int streak = 0;
    private int prestige = 0;
    private int mapNode = 0;
    private int boosters = 0;

    private int skInsight = 1;
    private int skTech = 1;
    private int skCharisma = 1;
    private int skNerve = 1;

    private int dailyStreak = 0;
    private String lastDaily;

    @Lob
    private String achievements = "[]";   // JSON-массив ключей

    public PlayerProfile() {}
    public PlayerProfile(String id, String firstName, String username) {
        this.id = id; this.firstName = firstName; this.username = username;
    }

    // ── getters / setters ──
    public String getId(){return id;} public void setId(String v){id=v;}
    public String getFirstName(){return firstName;} public void setFirstName(String v){firstName=v;}
    public String getUsername(){return username;} public void setUsername(String v){username=v;}
    public int getLevel(){return level;} public void setLevel(int v){level=v;}
    public int getXp(){return xp;} public void setXp(int v){xp=v;}
    public int getEnergy(){return energy;} public void setEnergy(int v){energy=v;}
    public int getMaxEnergy(){return maxEnergy;} public void setMaxEnergy(int v){maxEnergy=v;}
    public int getCredits(){return credits;} public void setCredits(int v){credits=v;}
    public int getCasesSolved(){return casesSolved;} public void setCasesSolved(int v){casesSolved=v;}
    public int getStreak(){return streak;} public void setStreak(int v){streak=v;}
    public int getPrestige(){return prestige;} public void setPrestige(int v){prestige=v;}
    public int getMapNode(){return mapNode;} public void setMapNode(int v){mapNode=v;}
    public int getBoosters(){return boosters;} public void setBoosters(int v){boosters=v;}
    public int getSkInsight(){return skInsight;} public void setSkInsight(int v){skInsight=v;}
    public int getSkTech(){return skTech;} public void setSkTech(int v){skTech=v;}
    public int getSkCharisma(){return skCharisma;} public void setSkCharisma(int v){skCharisma=v;}
    public int getSkNerve(){return skNerve;} public void setSkNerve(int v){skNerve=v;}
    public int getDailyStreak(){return dailyStreak;} public void setDailyStreak(int v){dailyStreak=v;}
    public String getLastDaily(){return lastDaily;} public void setLastDaily(String v){lastDaily=v;}
    public String getAchievements(){return achievements;} public void setAchievements(String v){achievements=v;}
}
