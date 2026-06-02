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
import java.util.concurrent.ConcurrentHashMap;

@Controller
public class TribunalController {
    
    // Временная база данных в памяти сервера (пока не подключим PostgreSQL)
    private final Map<String, CaseItem> database = new ConcurrentHashMap<>();

    public TribunalController() {
        // Заполняем ленту топовым контентом
        database.put("1", new CaseItem("1", CaseType.CONFESSION, "Исповедь", "Я работаю баристой и тайно наливаю обычный кофе клиентам, которые просят декаф и при этом хамят мне."));
        database.put("2", new CaseItem("2", CaseType.RED_FLAG, "Красный Флаг", "На первом свидании парень попросил разделить счет пополам, хотя сам позвал меня в дорогой ресторан. Это красный флаг?"));
        database.put("3", new CaseItem("3", CaseType.HOT_TAKE, "База или Бред", "Люди, которые отправляют голосовые сообщения длиннее минуты, не уважают чужое время. За это нужно блокировать в мессенджерах."));
    }

    // Сервер слушает канал /vote
    @MessageMapping("/vote")
    // И отвечает всем в канал /topic/live-results
    @SendTo("/topic/live-results")
    public VoteResult processVote(@Payload VoteMessage vote) {
        CaseItem caseItem = database.get(vote.getCaseId());
        
        if (caseItem != null) {
            caseItem.addVote(vote.getDirection()); // Регистрируем голос
            
            // Отправляем всем пользователям новые проценты для живого графика
            return new VoteResult(
                caseItem.getId(), 
                caseItem.getTotalVotes(), 
                caseItem.getLeftPercent(), 
                caseItem.getRightPercent()
            );
        }
        return null;
    }
}
