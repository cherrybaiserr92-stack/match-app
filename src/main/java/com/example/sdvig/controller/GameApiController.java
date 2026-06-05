package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService authService;
    private final PlayerProfileRepository profileRepo;

    public GameApiController(TelegramAuthService authService, PlayerProfileRepository profileRepo) {
        this.authService = authService;
        this.profileRepo = profileRepo;
    }

    // Эндпоинт для тихой загрузки внутри Telegram
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

    // Эндпоинт для виджета авторизации из браузера
    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, String> payload) {
        if (!authService.validateWidgetAuth(payload)) {
            return ResponseEntity.status(401).body("Invalid Widget signature");
        }
        return processUser(payload.get("id"), payload.get("username"), payload.get("first_name"));
    }

    // Универсальная регистрация/вход
    private ResponseEntity<?> processUser(String tgId, String username, String firstName) {
        String providerId = "tg:" + tgId;
        
        PlayerProfile profile = profileRepo.findByProviderId(providerId).orElseGet(() -> {
            PlayerProfile p = new PlayerProfile();
            p.setProviderId(providerId);
            p.setLevel(1);
            p.setExperience(0);
            return p;
        });

        profile.setUsername(username);
        profile.setFirstName(firstName);
        profileRepo.save(profile);
        
        return ResponseEntity.ok(profile);
    }
}
