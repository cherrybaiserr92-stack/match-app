package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.AiQuestService;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    @Autowired private TelegramAuthService authService;
    @Autowired private AiQuestService aiQuestService;
    @Autowired private PlayerProfileRepository profileRepository;

    @PostMapping("/profile")
    public ResponseEntity<?> getOrCreateProfile(@RequestHeader("X-TG-Auth") String initData, @RequestBody Map<String, Object> body) {
        if (!authService.validateInitData(initData)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Telegram Signature");
        }
        
        Long tgId = Long.parseLong(body.get("telegramId").toString());
        String username = (String) body.get("username");
        
        Optional<PlayerProfile> existing = profileRepository.findById(tgId);
        if (existing.isPresent()) {
            return ResponseEntity.ok(existing.get());
        }
        
        PlayerProfile newProfile = new PlayerProfile();
        newProfile.setTelegramId(tgId);
        newProfile.setUsername(username);
        newProfile.setArchetype((String) body.getOrDefault("archetype", "detective"));
        profileRepository.save(newProfile);
        
        return ResponseEntity.ok(newProfile);
    }

    @PostMapping("/sync")
    public ResponseEntity<?> syncProgress(@RequestHeader("X-TG-Auth") String initData, @RequestBody PlayerProfile updatedProfile) {
        if (!authService.validateInitData(initData)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Security error");
        }
        profileRepository.save(updatedProfile);
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    @GetMapping("/case")
    public ResponseEntity<?> getCase(@RequestHeader("X-TG-Auth") String initData, @RequestParam String archetype, @RequestParam int level) {
        if (!authService.validateInitData(initData)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Security error");
        }
        String text = aiQuestService.generateCaseText(archetype, level);
        return ResponseEntity.ok(Map.of("text", text));
    }
}
