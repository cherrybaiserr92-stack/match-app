package com.example.sdvig.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
public class TelegramOIDCService {

    @Value("${telegram.oidc.client-id:}")
    private String clientId;

    @Value("${telegram.oidc.client-secret:}")
    private String clientSecret;

    @Value("${app.base-url:}")
    private String baseUrl;

    private final ObjectMapper mapper = new ObjectMapper();

    public boolean isConfigured() {
        return clientId != null && !clientId.isBlank()
            && clientSecret != null && !clientSecret.isBlank();
    }

    /**
     * Exchange authorization code for Telegram user info.
     * Returns map with keys: id, first_name, username, photo_url
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> exchangeCode(String code) throws Exception {
        if (!isConfigured()) {
            throw new IllegalStateException("Telegram OIDC not configured");
        }

        String redirectUri = baseUrl.endsWith("/")
            ? baseUrl + "auth/oidc-callback"
            : baseUrl + "/auth/oidc-callback";

        // 1. Exchange code for access token
        String tokenUrl = "https://id.telegram.org/auth/token";
        String body = "grant_type=authorization_code"
            + "&code=" + enc(code)
            + "&client_id=" + enc(clientId)
            + "&client_secret=" + enc(clientSecret)
            + "&redirect_uri=" + enc(redirectUri);

        String tokenJson = post(tokenUrl, body, "application/x-www-form-urlencoded", null);
        Map<?, ?> tokenMap = mapper.readValue(tokenJson, Map.class);

        if (tokenMap.containsKey("error")) {
            throw new Exception("Token error: " + tokenMap.get("error_description"));
        }

        String accessToken = (String) tokenMap.get("access_token");
        if (accessToken == null || accessToken.isBlank()) {
            throw new Exception("No access_token in response");
        }

        // 2. Get user info
        String userInfoUrl = "https://id.telegram.org/auth/userinfo";
        String userJson = get(userInfoUrl, "Bearer " + accessToken);
        Map<String, Object> userInfo = mapper.readValue(userJson, Map.class);

        return normalise(userInfo);
    }

    /** Map OIDC claims to our standard keys */
    private Map<String, Object> normalise(Map<String, Object> raw) {
        // OIDC may use "sub" instead of "id"
        if (!raw.containsKey("id") && raw.containsKey("sub")) {
            raw.put("id", raw.get("sub"));
        }
        // "given_name" → "first_name"
        if (!raw.containsKey("first_name") && raw.containsKey("given_name")) {
            raw.put("first_name", raw.get("given_name"));
        }
        // "preferred_username" → "username"
        if (!raw.containsKey("username") && raw.containsKey("preferred_username")) {
            raw.put("username", raw.get("preferred_username"));
        }
        return raw;
    }

    // ── HTTP helpers ─────────────────────────

    private String post(String url, String body, String contentType, String auth) throws Exception {
        HttpURLConnection c = open(url);
        c.setRequestMethod("POST");
        c.setDoOutput(true);
        c.setRequestProperty("Content-Type", contentType);
        if (auth != null) c.setRequestProperty("Authorization", auth);
        try (OutputStream os = c.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }
        return read(c);
    }

    private String get(String url, String auth) throws Exception {
        HttpURLConnection c = open(url);
        c.setRequestMethod("GET");
        if (auth != null) c.setRequestProperty("Authorization", auth);
        return read(c);
    }

    private HttpURLConnection open(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(8000);
        c.setReadTimeout(8000);
        return c;
    }

    private String read(HttpURLConnection c) throws Exception {
        int code = c.getResponseCode();
        InputStream is = code >= 400 ? c.getErrorStream() : c.getInputStream();
        if (is == null) throw new Exception("Empty response, HTTP " + code);
        return new String(is.readAllBytes(), StandardCharsets.UTF_8);
    }

    private String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}

