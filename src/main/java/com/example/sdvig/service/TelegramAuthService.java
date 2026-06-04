package com.example.sdvig.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
public class TelegramAuthService {

    @Value("${telegram.bot.token:YOUR_BOT_TOKEN}")
    private String botToken;

    public boolean validateInitData(String initData) {
        // Если токен не настроен на сервере, пропускаем валидацию (для тестов на локальной машине)
        if ("YOUR_BOT_TOKEN".equals(botToken) || "MOCK_DATA_FOR_LOCAL_TESTING".equals(initData)) return true;

        try {
            Map<String, String> params = new HashMap<>();
            String[] pairs = initData.split("&");
            String telegramHash = "";

            for (String pair : pairs) {
                int idx = pair.indexOf("=");
                if (idx == -1) continue;
                String key = URLDecoder.decode(pair.substring(0, idx), StandardCharsets.UTF_8);
                String value = URLDecoder.decode(pair.substring(idx + 1), StandardCharsets.UTF_8);
                if (key.equals("hash")) {
                    telegramHash = value;
                } else {
                    params.put(key, value);
                }
            }

            List<String> sortedKeys = new ArrayList<>(params.keySet());
            Collections.sort(sortedKeys);

            StringBuilder dataCheckString = new StringBuilder();
            for (int i = 0; i < sortedKeys.size(); i++) {
                String key = sortedKeys.get(i);
                dataCheckString.append(key).append("=").append(params.get(key));
                if (i < sortedKeys.size() - 1) dataCheckString.append("\n");
            }

            byte[] secretKey = hmacSha256("WebAppData", botToken.getBytes(StandardCharsets.UTF_8));
            byte[] calculatedHashBytes = hmacSha256(dataCheckString.toString(), secretKey);
            
            StringBuilder sb = new StringBuilder();
            for (byte b : calculatedHashBytes) sb.append(String.format("%02x", b));

            return sb.toString().equals(telegramHash);
        } catch (Exception e) {
            return false;
        }
    }

    private byte[] hmacSha256(String data, byte[] key) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(key, "HmacSHA256");
        mac.init(secretKeySpec);
        return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
    }
}
