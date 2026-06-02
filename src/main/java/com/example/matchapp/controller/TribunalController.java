package com.example.matchapp.controller;

import com.example.matchapp.model.CaseItem;
import com.example.matchapp.model.CaseType;
import com.example.matchapp.dto.VoteMessage;
import com.example.matchapp.dto.VoteResult;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Controller
public class TribunalController {
    
    private final Map<String, CaseItem> database = new ConcurrentHashMap<>();

    public TribunalController() {
        database.put("1", new CaseItem("1", CaseType.CONFESSION, "Исповедь", "Я работаю баристой и тайно наливаю обычный кофе клиентам..."));
        database.put("2", new CaseItem("2", CaseType.RED_FLAG, "Красный Флаг", "На первом свидании парень попросил разделить счет пополам..."));
    }

    // Обработка голосов
    @MessageMapping("/vote")
    @SendTo("/topic/live-results")
    public VoteResult processVote(@Payload VoteMessage vote) {
        CaseItem caseItem = database.get(vote.getCaseId());
        if (caseItem != null) {
            caseItem.addVote(vote.getDirection());
            return new VoteResult(caseItem.getId(), caseItem.getTotalVotes(), caseItem.getLeftPercent(), caseItem.getRightPercent());
        }
        return null;
    }

    // Создание нового дела пользователем
    @MessageMapping("/create")
    @SendTo("/topic/new-cases")
    public CaseItem createCase(@Payload CaseItem newCase) {
        // Генерируем уникальный ID для нового дела
        String id = UUID.randomUUID().toString().substring(0, 8);
        CaseItem item = new CaseItem(id, newCase.getType(), newCase.getType().name(), newCase.getContent());
        database.put(id, item);
        return item;
    }
}
