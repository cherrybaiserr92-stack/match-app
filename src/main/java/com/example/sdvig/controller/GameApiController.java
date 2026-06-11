package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerRepository;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class GameApiController {

    private final PlayerRepository repo;
    private final TelegramAuthService tgAuth;

    public GameApiController(PlayerRepository repo, TelegramAuthService tgAuth) {
        this.repo = repo; this.tgAuth = tgAuth;
    }

    /* ── вход через Telegram Mini App ── */
    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String,String> body) {
        String initData = body.get("initData");
        Map<String,String> u = tgAuth.validate(initData);
        if (u == null || u.get("id") == null)
            return ResponseEntity.status(401).body(Map.of("error", "invalid_init_data"));

        String id = "tg:" + u.get("id");
        PlayerProfile p = repo.findById(id).orElseGet(() ->
            new PlayerProfile(id, u.getOrDefault("first_name","Агент"), u.get("username")));
        p.setFirstName(u.getOrDefault("first_name", p.getFirstName()));
        repo.save(p);

        // простой токен (для PoC) — id; в продакшене заменить на JWT
        return ResponseEntity.ok(Map.of(
            "token", id,
            "user", Map.of("id", u.get("id"),
                           "firstName", p.getFirstName(),
                           "name", p.getFirstName()),
            "profile", toDto(p)
        ));
    }

    /* ── сохранение профиля ── */
    @PutMapping("/profile")
    public ResponseEntity<?> save(@RequestHeader(value="Authorization",required=false) String auth,
                                  @RequestBody Map<String,Object> dto) {
        String id = bearer(auth);
        if (id == null) return ResponseEntity.status(401).build();
        PlayerProfile p = repo.findById(id).orElse(null);
        if (p == null) return ResponseEntity.status(404).build();
        applyDto(p, dto);
        repo.save(p);
        return ResponseEntity.ok(Map.of("ok", true));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> get(@RequestHeader(value="Authorization",required=false) String auth) {
        String id = bearer(auth);
        if (id == null) return ResponseEntity.status(401).build();
        return repo.findById(id).<ResponseEntity<?>>map(p -> ResponseEntity.ok(toDto(p)))
                .orElse(ResponseEntity.status(404).build());
    }

    @GetMapping("/health")
    public Map<String,Object> health(){ return Map.of("status","ok"); }

    // ── helpers ──
    private String bearer(String h){
        if (h == null || !h.startsWith("Bearer ")) return null;
        return h.substring(7);
    }
    private Map<String,Object> toDto(PlayerProfile p){
        Map<String,Object> m = new HashMap<>();
        m.put("level",p.getLevel()); m.put("xp",p.getXp());
        m.put("energy",p.getEnergy()); m.put("maxEnergy",p.getMaxEnergy());
        m.put("credits",p.getCredits()); m.put("casesSolved",p.getCasesSolved());
        m.put("streak",p.getStreak()); m.put("prestige",p.getPrestige());
        m.put("mapNode",p.getMapNode()); m.put("boosters",p.getBoosters());
        m.put("dailyStreak",p.getDailyStreak()); m.put("lastDaily",p.getLastDaily());
        Map<String,Object> sk = new HashMap<>();
        sk.put("insight",p.getSkInsight()); sk.put("tech",p.getSkTech());
        sk.put("charisma",p.getSkCharisma()); sk.put("nerve",p.getSkNerve());
        m.put("skills",sk);
        m.put("achievements",p.getAchievements());
        return m;
    }
    @SuppressWarnings("unchecked")
    private void applyDto(PlayerProfile p, Map<String,Object> d){
        if(d.containsKey("level")) p.setLevel(num(d.get("level")));
        if(d.containsKey("xp")) p.setXp(num(d.get("xp")));
        if(d.containsKey("energy")) p.setEnergy(num(d.get("energy")));
        if(d.containsKey("maxEnergy")) p.setMaxEnergy(num(d.get("maxEnergy")));
        if(d.containsKey("credits")) p.setCredits(num(d.get("credits")));
        if(d.containsKey("casesSolved")) p.setCasesSolved(num(d.get("casesSolved")));
        if(d.containsKey("streak")) p.setStreak(num(d.get("streak")));
        if(d.containsKey("prestige")) p.setPrestige(num(d.get("prestige")));
        if(d.containsKey("mapNode")) p.setMapNode(num(d.get("mapNode")));
        if(d.containsKey("boosters")) p.setBoosters(num(d.get("boosters")));
        if(d.containsKey("dailyStreak")) p.setDailyStreak(num(d.get("dailyStreak")));
        if(d.get("lastDaily")!=null) p.setLastDaily(d.get("lastDaily").toString());
        Object sk=d.get("skills");
        if(sk instanceof Map){ Map<String,Object> s=(Map<String,Object>)sk;
            if(s.containsKey("insight")) p.setSkInsight(num(s.get("insight")));
            if(s.containsKey("tech")) p.setSkTech(num(s.get("tech")));
            if(s.containsKey("charisma")) p.setSkCharisma(num(s.get("charisma")));
            if(s.containsKey("nerve")) p.setSkNerve(num(s.get("nerve"))); }
        Object ach=d.get("achievements");
        if(ach!=null) p.setAchievements(ach.toString());
    }
    private int num(Object o){ try{ return (int)Math.round(Double.parseDouble(o.toString())); }catch(Exception e){ return 0; } }
}
