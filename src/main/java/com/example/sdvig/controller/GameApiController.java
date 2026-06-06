package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.AiQuestService;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService    authService;
    private final PlayerProfileRepository profileRepo;
    private final AiQuestService         aiQuestService;
    private final Random                 random = new Random();

    public GameApiController(TelegramAuthService authService,
                             PlayerProfileRepository profileRepo,
                             AiQuestService aiQuestService) {
        this.authService    = authService;
        this.profileRepo    = profileRepo;
        this.aiQuestService = aiQuestService;
    }

    // ── Auth ──────────────────────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody java.util.Map<String, Object> payload) {
        try {
            String initData = (String) payload.get("initData");
            if (!authService.validateWebAppInitData(initData)) {
                return ResponseEntity.status(401).body("Invalid WebApp signature.");
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> initDataUnsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (initDataUnsafe == null || !initDataUnsafe.containsKey("user")) {
                return ResponseEntity.status(400).body("User data missing");
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> user = (Map<String, Object>) initDataUnsafe.get("user");
            return processUser(String.valueOf(user.get("id")),
                               (String) user.get("username"),
                               (String) user.get("first_name"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, String> payload) {
        try {
            if (!authService.validateWidgetAuth(payload)) {
                return ResponseEntity.status(401).body("Invalid widget signature");
            }
            return processUser(payload.get("id"), payload.get("username"), payload.get("first_name"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    private ResponseEntity<?> processUser(String tgId, String username, String firstName) {
        String providerId = "tg:" + tgId;
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile();
            np.setProviderId(providerId);
            return np;
        });
        if (username  != null) p.setUsername(username);
        if (firstName != null) p.setFirstName(firstName);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Case ──────────────────────────────────

    @GetMapping("/case")
    public ResponseEntity<?> getCase(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String json = aiQuestService.generateCaseJson(p.getArchetype(), p.getRank());
        return ResponseEntity.ok(json);
    }

    // ── Choice ────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(@RequestParam String providerId,
                                        @RequestParam String direction) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getEnergy() < 10) {
            return ResponseEntity.badRequest().body("Недостаточно энергии! Нужен кофе.");
        }

        int energyCost    = Math.max(3, 12 - p.getSkill2());
        int baseXp        = 15 + random.nextInt(10);
        int xpGained      = baseXp + (p.getSkill1() * 4);
        int creditsGained = 10 + random.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + creditsGained);
        p.setTotalCases(p.getTotalCases() + 1);

        int xpRequired = p.getRank() * 150;
        if (p.getXp() >= xpRequired) {
            p.setXp(p.getXp() - xpRequired);
            p.setRank(p.getRank() + 1);
        }

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  creditsGained,
            "energyLost",     energyCost
        ));
    }

    // ── Skill upgrade ─────────────────────────

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                          @RequestParam int skillNum) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        int curLevel = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost     = 50 * curLevel;
        if (p.getCredits() < cost) {
            return ResponseEntity.badRequest().body("Недостаточно кредитов.");
        }
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(p.getSkill1() + 1);
        else               p.setSkill2(p.getSkill2() + 1);

        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Buy coffee ────────────────────────────

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getCredits() < 40) return ResponseEntity.badRequest().body("Нужно 40 кредитов.");
        p.setCredits(p.getCredits() - 40);
        p.setEnergy(Math.min(100, p.getEnergy() + 35));
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Daily bonus ───────────────────────────

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDailyBonus(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        String today  = LocalDate.now().toString(); // "YYYY-MM-DD"
        String last   = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();
        boolean avail = !today.equals(last);

        return ResponseEntity.ok(Map.of(
            "available", avail,
            "streak",    p.getStreak()
        ));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDailyBonus(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        String today = LocalDate.now().toString();
        String last  = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();

        if (today.equals(last)) {
            return ResponseEntity.badRequest().body("Бонус уже получен сегодня.");
        }

        // Check streak continuity (yesterday)
        String yesterday = LocalDate.now().minusDays(1).toString();
        int newStreak = yesterday.equals(last) ? p.getStreak() + 1 : 1;

        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(newStreak);
        p.setLastDailyBonus(today);

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of("profile", p));
    }

    // ── Advance game level ────────────────────

    @PostMapping("/advance-level")
    public ResponseEntity<?> advanceLevel(@RequestParam String providerId,
                                          @RequestParam String gameType) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        switch (gameType) {
            case "detective" -> p.setDetectiveLvl(Math.min(100, p.getDetectiveLvl() + 1));
            case "doctor"    -> p.setDoctorLvl(Math.min(100, p.getDoctorLvl() + 1));
            case "universal" -> p.setUniversalLvl(Math.min(100, p.getUniversalLvl() + 1));
            default          -> { return ResponseEntity.badRequest().body("Unknown game type"); }
        }

        // Reward for completing a game level
        p.setXp(p.getXp() + 50);
        int xpRequired = p.getRank() * 150;
        if (p.getXp() >= xpRequired) {
            p.setXp(p.getXp() - xpRequired);
            p.setRank(p.getRank() + 1);
        }

        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }
}

