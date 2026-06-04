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

    public String generateCaseText(String archetype, int level) {
        if ("NONE".equals(apiKey)) {
            return getFallbackCase(archetype, level);
        }

        String systemPrompt = "Ты — бэкенд движок детективной игры 'Сдвиг'. Твоя задача — сгенерировать ОДНО описание архивного дела или инцидента. " +
                "КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО упоминать роботов, андроидов, ИИ или фантастику. Только суровый кинематографичный реализм (криминалистика, подделка документов, логи серверов, экономические преступления). " +
                "Сюжет должен подходить под класс оперативника: " + archetype + ". Уровень сложности кейса (от 1 до 100): " + level;

        try {
            Map<String, Object> requestBody = Map.of(
                "model", "deepseek-chat",
                "messages", List.of(
                    Map.of("role", "system", "content", systemPrompt),
                    Map.of("role", "user", "content", "Сгенерируй новое запутанное описание дела длиной до 35 слов.")
                ),
                "max_tokens", 150,
                "temperature", 0.7
            );

            Map<String, Object> response = webClient.post()
                    .uri(apiUrl)
                    .header("Authorization", "Bearer " + apiKey)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
            Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
            return (String) message.get("content");
            
        } catch (Exception e) {
            return getFallbackCase(archetype, level);
        }
    }

    private String getFallbackCase(String archetype, int level) {
        if ("detective".equals(archetype)) {
            return "[Архив #" + (100 + level) + "] Несоответствие в финансовых отчетах. Главный бухгалтер утверждает, что транзакции проводились удаленно, но системные логи указывают на использование физического токена в офисе.";
        } else if ("doctor".equals(archetype)) {
            return "[Архив #" + (200 + level) + "] Свидетель уверяет, что не знал жертву. Однако во время допроса датчики зафиксировали резкий скачок пульса и изменение микромимики при упоминании адреса происшествия.";
        }
        return "[Архив #" + (300 + level) + "] Обнаружены следы постороннего вмешательства в распределительный щит. Очевидцы путаются в хронологии отключения электричества в блоке.";
    }
}
