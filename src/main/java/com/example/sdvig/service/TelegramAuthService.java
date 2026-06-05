package com.example.sdvig.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class TelegramAuthService {

    @Value("${TELEGRAM_BOT_TOKEN:}")
    private String botToken;

    // 1. Проверка для входа внутри самого Telegram (Mini App)
    public boolean validateWebAppInitData(String initData) {
        try {
            if (initData == null || botToken == null || botToken.isEmpty()) return false;
            
            Map<String, String> parsed = Arrays.stream(initData.split("&"))
                    .map(param -> param.split("=", 2))
                    .collect(Collectors.toMap(
                            kv -> URLDecoder.decode(kv[0], StandardCharsets.UTF_8),
                            kv -> kv.length > 1 ? URLDecoder.decode(kv[1], StandardCharsets.UTF_8) : ""
                    ));

            String hash = parsed.remove("hash");
            if (hash == null) return false;

            String dataCheckString = parsed.entrySet().stream()
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> e.getKey() + "=" + e.getValue())
                    .collect(Collectors.joining("\n"));

            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec("WebAppData".getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] secretKey = mac.doFinal(botToken.getBytes(StandardCharsets.UTF_8));

            Mac macDataCheck = Mac.getInstance("HmacSHA256");
            macDataCheck.init(new SecretKeySpec(secretKey, "HmacSHA256"));
            byte[] calculatedHash = macDataCheck.doFinal(dataCheckString.getBytes(StandardCharsets.UTF_8));

            return bytesToHex(calculatedHash).equals(hash);
        } catch (Exception e) {
            return false;
        }
    }

    // 2. Проверка для входа через браузер (Telegram Login Widget)
    public boolean validateWidgetAuth(Map<String, String> payload) {
        try {
            if (botToken == null || botToken.isEmpty()) return false;
            
            String hash = payload.remove("hash");
            if (hash == null) return false;

            String dataCheckString = payload.entrySet().stream()
                    .filter(e -> e.getValue() != null && !e.getValue().isEmpty())
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> e.getKey() + "=" + e.getValue())
                    .collect(Collectors.joining("\n"));

            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] secretKey = digest.digest(botToken.getBytes(StandardCharsets.UTF_8));

            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secretKey, "HmacSHA256"));
            byte[] calculatedHash = mac.doFinal(dataCheckString.getBytes(StandardCharsets.UTF_8));

            return bytesToHex(calculatedHash).equals(hash);
        } catch (Exception e) {
            return false;
        }
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
