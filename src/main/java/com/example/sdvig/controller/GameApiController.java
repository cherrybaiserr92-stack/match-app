package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService     authService;
    private final PlayerProfileRepository profileRepo;
    private final Random                  rng = new Random();

    public GameApiController(TelegramAuthService authService,
                             PlayerProfileRepository profileRepo) {
        this.authService = authService;
        this.profileRepo = profileRepo;
    }

    // ── Auth: Telegram WebApp ──────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String, Object> payload) {
        try {
            String initData = (String) payload.get("initData");
            if (!authService.validateWebAppInitData(initData))
                return ResponseEntity.status(401).body("Invalid WebApp signature.");

            @SuppressWarnings("unchecked")
            var unsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (unsafe == null || !unsafe.containsKey("user"))
                return ResponseEntity.status(400).body("User data missing");

            @SuppressWarnings("unchecked")
            var u = (Map<String, Object>) unsafe.get("user");
            return doLogin("tg:" + u.get("id"), str(u.get("username")), str(u.get("first_name")));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    // ── Auth: Telegram Widget ──────────────────

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, Object> payload) {
        try {
            if (!authService.validateWidgetAuth(payload))
                return ResponseEntity.status(401).body("Invalid widget signature");
            return doLogin("tg:" + payload.get("id"),
                    str(payload.get("username")), str(payload.get("first_name")));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    // ── Auth: Guest ───────────────────────────

    @PostMapping("/auth/guest")
    public ResponseEntity<?> authGuest(@RequestBody Map<String, String> payload) {
        String deviceId = payload.getOrDefault("deviceId", UUID.randomUUID().toString());
        // sanitise – only alphanum + dash
        deviceId = deviceId.replaceAll("[^a-zA-Z0-9\\-]", "").substring(0, Math.min(deviceId.length(), 64));
        return doLogin("guest:" + deviceId, "Гость", "Гость");
    }

    // ── Shared login helper ───────────────────

    private ResponseEntity<?> doLogin(String pid, String username, String firstName) {
        PlayerProfile p = profileRepo.findByProviderId(pid).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile();
            np.setProviderId(pid);
            np.setCredits(150); // starter credits
            return np;
        });
        if (username  != null) p.setUsername(username);
        if (firstName != null) p.setFirstName(firstName);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    private String str(Object o) { return o == null ? null : String.valueOf(o); }

    // ── Choice ────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(@RequestParam String providerId,
                                        @RequestParam String direction) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getEnergy() < 5)
            return ResponseEntity.badRequest().body("Нет энергии — нужен кофе ☕");

        int energyCost    = Math.max(3, 12 - p.getSkill2());
        int baseXp        = 15 + rng.nextInt(10);
        int xpGained      = baseXp + p.getSkill1() * 4;
        int creditsGained = 10 + rng.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + creditsGained);
        p.setTotalCases(p.getTotalCases() + 1);

        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  creditsGained,
            "energyLost",     energyCost
        ));
    }

    // ── Upgrade skill ─────────────────────────

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                          @RequestParam int skillNum) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        int cur  = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost = 50 * cur;
        if (p.getCredits() < cost)
            return ResponseEntity.badRequest().body("Нужно " + cost + " 💎");
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(cur + 1); else p.setSkill2(cur + 1);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Buy coffee ────────────────────────────

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getCredits() < 40) return ResponseEntity.badRequest().body("Нужно 40 💎");
        p.setCredits(p.getCredits() - 40);
        p.setEnergy(Math.min(100, p.getEnergy() + 35));
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Daily bonus ───────────────────────────

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDaily(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String today = LocalDate.now().toString();
        String last  = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();
        return ResponseEntity.ok(Map.of("available", !today.equals(last), "streak", p.getStreak()));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDaily(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String today = LocalDate.now().toString();
        if (today.equals(p.getLastDailyBonus()))
            return ResponseEntity.badRequest().body("Бонус уже получен сегодня");
        String yesterday = LocalDate.now().minusDays(1).toString();
        int streak = yesterday.equals(p.getLastDailyBonus()) ? p.getStreak() + 1 : 1;
        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(streak);
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
        if ("detective".equals(gameType))
            p.setDetectiveLvl(Math.min(100, p.getDetectiveLvl() + 1));
        p.setXp(p.getXp() + 50);
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }
}

