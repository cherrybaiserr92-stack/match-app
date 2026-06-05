package com.example.sdvig.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import java.util.Map;
import java.util.List;
import java.util.Random;

@Service
public class AiQuestService {

    @Value("${ai.api.key:NONE}")
    private String apiKey;

    @Value("${ai.api.url:https://api.openai.com/v1/chat/completions}")
    private String apiUrl;

    private final WebClient webClient = WebClient.builder().build();
    private final Random random = new Random();

    public String generateCaseJson(String archetype, int level) {
        if ("NONE".equals(apiKey)) {
            return getRandomFallback(archetype, level);
        }

        String systemPrompt = "Ты — ИИ-движок текстового нуар-квеста 'Сдвиг'. " +
                "Сгенерируй ОДНО уникальное дело строго в формате JSON без markdown. " +
                "Поля: \"text\" (суровый реализм, киберпреступления, допросы), " +
                "\"leftOption\", \"leftResult\" (последствия влево), " +
                "\"rightOption\", \"rightResult\" (последствия вправо). Уровень: " + level;

        try {
            Map<String, Object> requestBody = Map.of(
                "model", "deepseek-chat",
                "messages", List.of(
                    Map.of("role", "system", "content", systemPrompt),
                    Map.of("role", "user", "content", "Сгенерируй абсолютно новый инцидент.")
                ),
                "temperature", 0.9
            );

            Map<?, ?> response = webClient.post().uri(apiUrl)
                    .header("Authorization", "Bearer " + apiKey)
                    .bodyValue(requestBody).retrieve().bodyToMono(Map.class).block();

            List<?> choices = (List<?>) response.get("choices");
            Map<?, ?> message = (Map<?, ?>) ((Map<?, ?>) choices.get(0)).get("message");
            return (String) message.get("content");
        } catch (Exception e) {
            return getRandomFallback(archetype, level);
        }
    }

    private String getRandomFallback(String archetype, int level) {
        String[] cases = {
            "{\"text\": \"[Ур."+level+"] В логах корпоративной сети найден бэкдор. Следы ведут в терминал нижнего уровня.\", \"leftOption\": \"Стереть логи\", \"leftResult\": \"Вы стерли логи. Служба безопасности ничего не заметила.\", \"rightOption\": \"Запустить трейсер\", \"rightResult\": \"Трейсер выявил крота. Вы получили премию.\"}",
            "{\"text\": \"[Ур."+level+"] Информатор готов передать флешку с данными о подставных счетах, но требует гарантий.\", \"leftOption\": \"Угрожать\", \"leftResult\": \"Информатор испугался и отдал данные, но затаил обиду.\", \"rightOption\": \"Заплатить\", \"rightResult\": \"Вы потеряли кредиты, но получили чистую флешку.\"}",
            "{\"text\": \"[Ур."+level+"] Система видеонаблюдения сектора C отключилась на 4 минуты. Охранник путается в показаниях.\", \"leftOption\": \"Допросить жестко\", \"leftResult\": \"Охранник сломался и выдал подельников.\", \"rightOption\": \"Изучить сервер\", \"rightResult\": \"Вы нашли вирус, который глушил камеры. Отличная работа.\"}"
        };
        return cases[random.nextInt(cases.length)];
    }
}
