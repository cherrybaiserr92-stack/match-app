package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.AiQuestService;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService authService;
    private final PlayerProfileRepository profileRepo;
    private final AiQuestService aiQuestService;
    private final Random random = new Random();

    public GameApiController(TelegramAuthService authService, PlayerProfileRepository profileRepo, AiQuestService aiQuestService) {
        this.authService = authService;
        this.profileRepo = profileRepo;
        this.aiQuestService = aiQuestService;
    }

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String, Object> payload) {
        String initData = (String) payload.get("initData");
        if (!authService.validateWebAppInitData(initData)) {
            return ResponseEntity.status(401).body("Invalid WebApp signature");
        }
        Map<String, Object> initDataUnsafe = (Map<String, Object>) payload.get("initDataUnsafe");
        Map<String, Object> user = (Map<String, Object>) initDataUnsafe.get("user");
        return processUser(user.get("id").toString(), (String) user.get("username"), (String) user.get("first_name"));
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, String> payload) {
        if (!authService.validateWidgetAuth(payload)) {
            return ResponseEntity.status(401).body("Invalid Widget signature");
        }
        return processUser(payload.get("id"), payload.get("username"), payload.get("first_name"));
    }

    private ResponseEntity<?> processUser(String tgId, String username, String firstName) {
        String providerId = "tg:" + tgId;
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElseGet(() -> {
            PlayerProfile p = new PlayerProfile();
            p.setProviderId(providerId);
            return p;
        });
        profile.setUsername(username);
        profile.setFirstName(firstName);
        profileRepo.save(profile);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/case")
    public ResponseEntity<?> getCase(@RequestParam String providerId) {
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElse(null);
        if (profile == null) return ResponseEntity.badRequest().body("Profile not found");
        
        String json = aiQuestService.generateCaseJson(profile.getArchetype(), profile.getRank());
        return ResponseEntity.ok(json);
    }

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(@RequestParam String providerId, @RequestParam String direction) {
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElse(null);
        if (profile == null) return ResponseEntity.badRequest().body("Profile not found");

        if (profile.getEnergy() < 10) {
            return ResponseEntity.badRequest().body("Недостаточно энергии! Нужно выпить кофе.");
        }

        // Влияние Навыка 2 (Технологии) на расход энергии
        int energyCost = Math.max(3, 12 - profile.getSkill2());
        profile.setEnergy(Math.max(0, profile.getEnergy() - energyCost));

        // Влияние Навыка 1 (Проницательность) на получение опыта
        int baseXp = 15 + random.nextInt(10);
        int xpGained = baseXp + (profile.getSkill1() * 4);
        profile.setXp(profile.getXp() + xpGained);

        // Начисление кредитов за успешное действие
        int creditsGained = 10 + random.nextInt(15);
        profile.setCredits(profile.getCredits() + creditsGained);

        // Расчет повышения Ранга (каждый ранг требует больше опыта)
        int xpRequired = profile.getRank() * 150;
        if (profile.getXp() >= xpRequired) {
            profile.setXp(profile.getXp() - xpRequired);
            profile.setRank(profile.getRank() + 1);
        }

        profileRepo.save(profile);
        return ResponseEntity.ok(Map.of(
            "profile", profile,
            "xpGained", xpGained,
            "creditsGained", creditsGained,
            "energyLost", energyCost
        ));
    }

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId, @RequestParam int skillNum) {
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElse(null);
        if (profile == null) return ResponseEntity.badRequest().body("Profile not found");

        int cost = 50 * (skillNum == 1 ? profile.getSkill1() : profile.getSkill2());
        if (profile.getCredits() < cost) {
            return ResponseEntity.badRequest().body("Недостаточно кредитов для улучшения.");
        }

        profile.setCredits(profile.getCredits() - cost);
        if (skillNum == 1) {
            profile.setSkill1(profile.getSkill1() + 1);
        } else {
            profile.setSkill2(profile.getSkill2() + 1);
        }

        profileRepo.save(profile);
        return ResponseEntity.ok(profile);
    }

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElse(null);
        if (profile == null) return ResponseEntity.badRequest().body("Profile not found");

        if (profile.getCredits() < 40) {
            return ResponseEntity.badRequest().body("Кофе стоит 40 кредитов.");
        }

        profile.setCredits(profile.getCredits() - 40);
        profile.setEnergy(Math.min(100, profile.getEnergy() + 35));
        profileRepo.save(profile);
        return ResponseEntity.ok(profile);
    }
}
