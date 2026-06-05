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
        try {
            String initData = (String) payload.get("initData");
            
            // Проверка подписи Telegram
            if (!authService.validateWebAppInitData(initData)) {
                return ResponseEntity.status(401).body("Invalid WebApp signature. Токен бота не настроен или неверен.");
            }

            Map<String, Object> initDataUnsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (initDataUnsafe == null || !initDataUnsafe.containsKey("user")) {
                return ResponseEntity.status(400).body("User data is missing");
            }
            
            Map<String, Object> user = (Map<String, Object>) initDataUnsafe.get("user");
            String tgId = String.valueOf(user.get("id"));
            String username = (String) user.get("username");
            String firstName = (String) user.get("first_name");

            return processUser(tgId, username, firstName);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server Error: " + e.getMessage());
        }
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, String> payload) {
        try {
            if (!authService.validateWidgetAuth(payload)) {
                return ResponseEntity.status(401).body("Invalid Widget signature");
            }
            return processUser(payload.get("id"), payload.get("username"), payload.get("first_name"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server Error: " + e.getMessage());
        }
    }

    private ResponseEntity<?> processUser(String tgId, String username, String firstName) {
        String providerId = "tg:" + tgId;
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElseGet(() -> {
            PlayerProfile p = new PlayerProfile();
            p.setProviderId(providerId);
            return p;
        });
        
        if (username != null) profile.setUsername(username);
        if (firstName != null) profile.setFirstName(firstName);
        
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

        int energyCost = Math.max(3, 12 - profile.getSkill2());
        profile.setEnergy(Math.max(0, profile.getEnergy() - energyCost));

        int baseXp = 15 + random.nextInt(10);
        int xpGained = baseXp + (profile.getSkill1() * 4);
        profile.setXp(profile.getXp() + xpGained);

        int creditsGained = 10 + random.nextInt(15);
        profile.setCredits(profile.getCredits() + creditsGained);

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
