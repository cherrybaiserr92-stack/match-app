package com.example.sdvig.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Проверка Telegram Mini App initData (Вариант A).
 * Использует TELEGRAM_BOT_TOKEN. client_id/client_secret здесь не нужны:
 * Telegram Mini App подписывает данные именно bot token'ом.
 */
@Service
public class TelegramAuthService {

    @Value("${TELEGRAM_BOT_TOKEN:}")
    private String botToken;

    /** @return Map с полями пользователя, либо null если подпись неверна */
    public Map<String,String> validate(String initData) {
        if (initData == null || initData.isEmpty() || botToken == null || botToken.isEmpty())
            return null;
        try {
            // 1. распарсить query-string
            Map<String,String> params = new HashMap<>();
            for (String pair : initData.split("&")) {
                int i = pair.indexOf('=');
                if (i < 0) continue;
                String k = pair.substring(0, i);
                String v = URLDecoder.decode(pair.substring(i + 1), StandardCharsets.UTF_8);
                params.put(k, v);
            }
            String hash = params.remove("hash");
            if (hash == null) return null;

            // 2. data_check_string (отсортированные пары key=value через \n)
            List<String> keys = new ArrayList<>(params.keySet());
            Collections.sort(keys);
            StringBuilder dcs = new StringBuilder();
            for (String k : keys) {
                if (dcs.length() > 0) dcs.append('\n');
                dcs.append(k).append('=').append(params.get(k));
            }

            // 3. secret = HMAC_SHA256("WebAppData", botToken)
            byte[] secret = hmac("WebAppData".getBytes(StandardCharsets.UTF_8),
                                 botToken.getBytes(StandardCharsets.UTF_8));
            byte[] calc = hmac(secret, dcs.toString().getBytes(StandardCharsets.UTF_8));
            String calcHex = toHex(calc);

            if (!calcHex.equals(hash)) return null;

            // 4. проверка свежести (24ч)
            String authDate = params.get("auth_date");
            if (authDate != null) {
                long t = Long.parseLong(authDate);
                if (System.currentTimeMillis()/1000 - t > 86400) return null;
            }

            // 5. вытащить user
            Map<String,String> out = new HashMap<>();
            String userJson = params.get("user");
            if (userJson != null) {
                out.put("id", extract(userJson, "id"));
                out.put("first_name", extract(userJson, "first_name"));
                out.put("username", extract(userJson, "username"));
            }
            return out;
        } catch (Exception e) {
            return null;
        }
    }

    private byte[] hmac(byte[] key, byte[] data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key, "HmacSHA256"));
        return mac.doFinal(data);
    }
    private String toHex(byte[] b) {
        StringBuilder sb = new StringBuilder();
        for (byte x : b) sb.append(String.format("%02x", x));
        return sb.toString();
    }
    // примитивный extract из JSON user (без зависимостей)
    private String extract(String json, String field) {
        String key = "\"" + field + "\"";
        int i = json.indexOf(key);
        if (i < 0) return null;
        i = json.indexOf(':', i) + 1;
        while (i < json.length() && (json.charAt(i)==' ')) i++;
        if (json.charAt(i) == '"') {
            int j = json.indexOf('"', i + 1);
            return json.substring(i + 1, j);
        } else {
            int j = i;
            while (j < json.length() && "0123456789".indexOf(json.charAt(j)) >= 0) j++;
            return json.substring(i, j);
        }
    }
}
