package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.TelegramAuthService;
import com.example.sdvig.service.TelegramOIDCService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService     auth;
    private final TelegramOIDCService     oidc;
    private final PlayerProfileRepository repo;
    private final Random                  rng = new Random();

    public GameApiController(TelegramAuthService auth,
                             TelegramOIDCService oidc,
                             PlayerProfileRepository repo) {
        this.auth = auth;
        this.oidc = oidc;
        this.repo = repo;
    }

    // ────────────────────────────────────────────
    //  Auth endpoints
    // ────────────────────────────────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String, Object> payload) {
        try {
            String initData = str(payload.get("initData"));
            if (!auth.validateWebAppInitData(initData))
                return err(401, "Invalid WebApp signature");

            @SuppressWarnings("unchecked")
            var unsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (unsafe == null) return err(400, "Missing initDataUnsafe");

            @SuppressWarnings("unchecked")
            var u = (Map<String, Object>) unsafe.get("user");
            if (u == null) return err(400, "Missing user");

            return login("tg:" + u.get("id"), str(u.get("username")), str(u.get("first_name")));
        } catch (Exception e) {
            return err(500, "WebApp auth error: " + e.getMessage());
        }
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, Object> payload) {
        try {
            if (!auth.validateWidgetAuth(payload))
                return err(401, "Invalid widget signature");
            return login("tg:" + payload.get("id"),
                         str(payload.get("username")),
                         str(payload.get("first_name")));
        } catch (Exception e) {
            return err(500, "Widget auth error: " + e.getMessage());
        }
    }

    /** Telegram OpenID Connect — exchange code for profile */
    @PostMapping("/auth/oidc")
    public ResponseEntity<?> authOIDC(@RequestBody Map<String, String> payload) {
        String code = payload.getOrDefault("code", "").trim();
        if (code.isBlank()) return err(400, "Missing code");
        try {
            Map<String, Object> info = oidc.exchangeCode(code);
            String tgId = str(info.get("id") != null ? info.get("id") : info.get("sub"));
            if (tgId == null || tgId.isBlank()) return err(400, "No user id in OIDC response");
            return login("tg:" + tgId,
                         str(info.get("username")),
                         str(info.get("first_name")));
        } catch (Exception e) {
            return err(500, "OIDC error: " + e.getMessage());
        }
    }

    /** Guest / offline login via device fingerprint */
    @PostMapping("/auth/guest")
    public ResponseEntity<?> authGuest(@RequestBody Map<String, String> payload) {
        String raw = payload.getOrDefault("deviceId", UUID.randomUUID().toString());
        String deviceId = raw.replaceAll("[^a-zA-Z0-9\\-_]", "")
                             .substring(0, Math.min(raw.length(), 64));
        if (deviceId.isBlank()) deviceId = UUID.randomUUID().toString().replace("-", "");
        return login("guest:" + deviceId, "Гость", "Гость");
    }

    // ── Shared login helper ───────────────────

    private ResponseEntity<?> login(String pid, String username, String firstName) {
        PlayerProfile p = repo.findByProviderId(pid).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile();
            np.setProviderId(pid);
            np.setCredits(150);     // starter pack
            np.setEnergy(100);
            return np;
        });
        if (username  != null && !username.isBlank())  p.setUsername(username);
        if (firstName != null && !firstName.isBlank()) p.setFirstName(firstName);
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    // ────────────────────────────────────────────
    //  Game endpoints
    // ────────────────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> choice(
            @RequestParam String providerId,
            @RequestParam String direction,
            @RequestParam(defaultValue = "false") boolean special) {

        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");

        // Special move (swipe up) requires skill1 >= 3 and costs more energy
        int energyCost = special
            ? Math.max(8, 18 - p.getSkill2())
            : Math.max(3, 12 - p.getSkill2());

        if (p.getEnergy() < energyCost)
            return err(400, "Нет энергии — нужен кофе ☕ (" + energyCost + " ⚡)");

        int xpBase   = special ? 25 + rng.nextInt(10) : 15 + rng.nextInt(10);
        int xpGained = xpBase + p.getSkill1() * 4;
        int crGained = special ? 15 + rng.nextInt(20) : 10 + rng.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + crGained);
        p.setTotalCases(p.getTotalCases() + 1);

        // Rank up
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }

        repo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  crGained,
            "energyLost",     energyCost
        ));
    }

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                           @RequestParam int skillNum) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        int cur  = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost = 50 * cur;
        if (p.getCredits() < cost) return err(400, "Нужно " + cost + " 💎");
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(cur + 1); else p.setSkill2(cur + 1);
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        if (p.getCredits() < 40) return err(400, "Нужно 40 💎");
        p.setCredits(p.getCredits() - 40);
        p.setEnergy(Math.min(100, p.getEnergy() + 35));
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDaily(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        String today = LocalDate.now().toString();
        boolean avail = !today.equals(p.getLastDailyBonus());
        return ResponseEntity.ok(Map.of("available", avail, "streak", p.getStreak()));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDaily(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        String today = LocalDate.now().toString();
        if (today.equals(p.getLastDailyBonus()))
            return err(400, "Бонус уже получен сегодня");
        String yest = LocalDate.now().minusDays(1).toString();
        int streak = yest.equals(p.getLastDailyBonus()) ? p.getStreak() + 1 : 1;
        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(streak);
        p.setLastDailyBonus(today);
        repo.save(p);
        return ResponseEntity.ok(Map.of("profile", p));
    }

    @PostMapping("/advance-level")
    public ResponseEntity<?> advanceLevel(@RequestParam String providerId,
                                           @RequestParam String gameType) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        if ("detective".equals(gameType))
            p.setDetectiveLvl(Math.min(100, p.getDetectiveLvl() + 1));
        p.setXp(p.getXp() + 50);
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Helpers ──────────────────────────────

    private PlayerProfile find(String pid) {
        return repo.findByProviderId(pid).orElse(null);
    }

    private ResponseEntity<String> err(int status, String msg) {
        return ResponseEntity.status(status).body(msg);
    }

    private String str(Object o) { return o == null ? null : String.valueOf(o); }
}

