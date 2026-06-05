package com.example.sdvig.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import java.util.Map;
import java.util.List;

@Service
public class AiQuestService {

    @Value("${ai.api.key:NONE}")
    private String apiKey;

    @Value("${ai.api.url:https://api.openai.com/v1/chat/completions}")
    private String apiUrl;

    private final WebClient webClient = WebClient.builder().build();

    public String generateCaseJson(String archetype, int level) {
        if ("NONE".equals(apiKey)) {
            return getFallbackJson(archetype, level);
        }

        String systemPrompt = "Ты — ИИ-движок текстового детективного нуар-квеста 'Сдвиг'. " +
                "Твоя задача — сгенерировать ОДИН инцидент строго в формате JSON. Никакой фантастики, только суровый нуарный детективный реализм (улики, логи, допросы). " +
                "Ответ должен содержать исключительно валидный JSON-объект без разметки markdown (без ```json). " +
                "Поля JSON объекта:\n" +
                "\"text\": \"Описание запутанного инцидента или улики для класса " + archetype + " (уровень " + level + ")\",\n" +
                "\"leftOption\": \"Вариант действия игрока при свайпе влево (короткая фраза до 4 слов)\",\n" +
                "\"leftResult\": \"Сюжетное последствие и текстовый итог выбора влево (1-2 предложения)\",\n" +
                "\"rightOption\": \"Вариант действия игрока при свайпе вправо (короткая фраза до 4 слов)\",\n" +
                "\"rightResult\": \"Сюжетное последствие и текстовый итог выбора вправо (1-2 предложения)\"";

        try {
            Map<String, Object> requestBody = Map.of(
                "model", "deepseek-chat",
                "messages", List.of(
                    Map.of("role", "system", "content", systemPrompt),
                    Map.of("role", "user", "content", "Сгенерируй новое дело.")
                ),
                "temperature", 0.7
            );

            Map<?, ?> response = webClient.post()
                    .uri(apiUrl)
                    .header("Authorization", "Bearer " + apiKey)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            List<?> choices = (List<?>) response.get("choices");
            Map<?, ?> message = (Map<?, ?>) ((Map<?, ?>) choices.get(0)).get("message");
            return (String) message.get("content");
            
        } catch (Exception e) {
            return getFallbackJson(archetype, level);
        }
    }

    private String getFallbackJson(String archetype, int level) {
        return "{" +
                "\"text\": \"[Дело #" + level + "] Обнаружена подозрительная транзакция на сервере. Системные логи стерты, но терминал входа находится в комнате охраны.\"," +
                "\"leftOption\": \"Взломать терминал удаленно\"," +
                "\"leftResult\": \"Вы попытались взломать систему. Защита заблокировала доступ, но благодаря техническим навыкам вы успели перехватить логи.\"," +
                "\"rightOption\": \"Допросить охранника\"," +
                "\"rightResult\": \"Дежурный сильно нервничал, но после предъявления улик сознался и передал вам скрытую флешку с копией архива.\"" +
                "}";
    }
}
