package com.example.matchapp.controller;

import com.example.matchapp.dto.SwipeMessage;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class MatchController {
    
    // Телефон отправляет свайп сюда
    @MessageMapping("/swipe")
    // А сервер мгновенно рассылает его всем, кто сидит в этой комнате
    @SendTo("/topic/room")
    public SwipeMessage processSwipe(@Payload SwipeMessage message) {
        System.out.println("Получен свайп: User " + message.getUserId() + 
                           " свайпнул карточку " + message.getItemId() + 
                           " в сторону " + message.getDirection());
                           
        // Пока просто пересылаем событие всем остальным. 
        // Позже добавим сюда логику проверки "Совпало ли?"
        return message;
    }
}
