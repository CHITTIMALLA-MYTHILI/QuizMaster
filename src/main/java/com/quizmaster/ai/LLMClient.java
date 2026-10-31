package com.quizmaster.ai;

import java.net.ConnectException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LLMClient {

    private final HttpClient httpClient;

    public LLMClient() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public String generateCompletion(String systemPrompt, String userPrompt) throws Exception {
        if (!AIConfig.isConfigured()) {
            throw new IllegalStateException("QUIZMASTER_AI_API_KEY is not configured on the server. Please set the environment variable or configure ai.properties.");
        }

        String apiKey = AIConfig.getApiKey();
        String provider = AIConfig.getProvider();
        String model = AIConfig.getModel();
        int timeoutSeconds = AIConfig.getTimeoutSeconds();

        long startTime = System.currentTimeMillis();
        try {
            String result;
            if ("openai".equalsIgnoreCase(provider)) {
                result = callOpenAI(apiKey, model, systemPrompt, userPrompt, timeoutSeconds);
            } else {
                result = callGemini(apiKey, model, systemPrompt, userPrompt, timeoutSeconds);
            }
            long duration = System.currentTimeMillis() - startTime;
            System.out.printf("[QUIZMASTER-AI-DIAGNOSTIC] Provider: %s, Model: %s, Status: 200, Duration: %d ms%n",
                    provider, model, duration);
            return result;
        } catch (HttpTimeoutException e) {
            long duration = System.currentTimeMillis() - startTime;
            System.err.printf("[QUIZMASTER-AI-DIAGNOSTIC] Timeout after %d ms for Provider: %s, Model: %s%n",
                    duration, provider, model);
            throw new RuntimeException("The AI request timed out after " + timeoutSeconds + " seconds. Please try again with shorter text or fewer questions.");
        } catch (ConnectException e) {
            System.err.printf("[QUIZMASTER-AI-DIAGNOSTIC] Connection failure for Provider: %s: %s%n", provider, e.getMessage());
            throw new RuntimeException("Unable to connect to the AI service endpoint. Please check your internet connection.");
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            System.err.printf("[QUIZMASTER-AI-DIAGNOSTIC] Error after %d ms for Provider: %s: %s%n",
                    duration, provider, e.getMessage());
            throw e;
        }
    }

    private String callGemini(String apiKey, String model, String systemPrompt, String userPrompt, int timeoutSeconds) throws Exception {
        String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + apiKey;

        String combined = (systemPrompt != null && !systemPrompt.isEmpty())
                ? systemPrompt + "\n\nUser request:\n" + userPrompt
                : userPrompt;

        String jsonPayload = "{\"contents\":[{\"parts\":[{\"text\":" + escapeJson(combined) + "}]}]}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(timeoutSeconds))
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        int statusCode = response.statusCode();

        if (statusCode != 200) {
            handleErrorResponse("Gemini", statusCode, response.body());
        }

        return extractGeminiText(response.body());
    }

    private String callOpenAI(String apiKey, String model, String systemPrompt, String userPrompt, int timeoutSeconds) throws Exception {
        String endpoint = "https://api.openai.com/v1/chat/completions";

        String jsonPayload = "{\"model\":" + escapeJson(model) + ",\"messages\":["
                + "{\"role\":\"system\",\"content\":" + escapeJson(systemPrompt != null ? systemPrompt : "You are an educational assistant.") + "},"
                + "{\"role\":\"user\",\"content\":" + escapeJson(userPrompt) + "}"
                + "]}";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .timeout(Duration.ofSeconds(timeoutSeconds))
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        int statusCode = response.statusCode();

        if (statusCode != 200) {
            handleErrorResponse("OpenAI", statusCode, response.body());
        }

        return extractOpenAIText(response.body());
    }

    private void handleErrorResponse(String provider, int statusCode, String responseBody) {
        String reason;
        switch (statusCode) {
            case 400:
                reason = "The request payload was rejected by " + provider + " (HTTP 400). Please check your input length.";
                break;
            case 401:
            case 403:
                reason = provider + " authentication failed (HTTP " + statusCode + "). Please verify the server API key is valid and has active permissions.";
                break;
            case 404:
                reason = "The requested " + provider + " model was not found (HTTP 404). Please verify model name configuration.";
                break;
            case 429:
                reason = provider + " rate limit or quota exceeded (HTTP 429). Please wait a moment or check your API quota.";
                break;
            case 500:
            case 502:
            case 503:
            case 504:
                reason = provider + " service is temporarily unavailable (HTTP " + statusCode + "). Please try again shortly.";
                break;
            default:
                reason = provider + " API returned error (HTTP " + statusCode + ").";
                break;
        }

        // Check if there is a specific error message inside the body without leaking secrets
        if (responseBody != null) {
            if (responseBody.contains("RESOURCE_EXHAUSTED")) {
                reason = "API quota exceeded. Please check your account usage and limits.";
            } else if (responseBody.contains("API_KEY_INVALID") || responseBody.contains("invalid_api_key")) {
                reason = "Invalid API key configured on the server.";
            }
        }

        throw new RuntimeException(reason);
    }

    private String escapeJson(String text) {
        if (text == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        for (char c : text.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
            }
        }
        sb.append("\"");
        return sb.toString();
    }

    private String extractGeminiText(String json) {
        if (json == null) return "";

        // Check for safety block
        if (json.contains("\"blockReason\"") || json.contains("\"finishReason\": \"SAFETY\"")) {
            throw new RuntimeException("Content generation was blocked by the safety filter. Please ensure the study material contains educational text.");
        }

        // Match "text"\s*:\s*"..."
        Pattern pattern = Pattern.compile("\"text\"\\s*:\\s*\"");
        Matcher matcher = pattern.matcher(json);
        if (!matcher.find()) {
            return json;
        }

        int idx = matcher.end();
        int end = idx;
        boolean escaped = false;
        while (end < json.length()) {
            char c = json.charAt(end);
            if (c == '\\') {
                escaped = !escaped;
            } else if (c == '"' && !escaped) {
                break;
            } else {
                escaped = false;
            }
            end++;
        }

        String raw = json.substring(idx, end);
        return unescapeJsonString(raw);
    }

    private String extractOpenAIText(String json) {
        if (json == null) return "";

        Pattern pattern = Pattern.compile("\"content\"\\s*:\\s*\"");
        Matcher matcher = pattern.matcher(json);
        if (!matcher.find()) {
            return json;
        }

        int idx = matcher.end();
        int end = idx;
        boolean escaped = false;
        while (end < json.length()) {
            char c = json.charAt(end);
            if (c == '\\') {
                escaped = !escaped;
            } else if (c == '"' && !escaped) {
                break;
            } else {
                escaped = false;
            }
            end++;
        }

        String raw = json.substring(idx, end);
        return unescapeJsonString(raw);
    }

    private String unescapeJsonString(String s) {
        StringBuilder sb = new StringBuilder();
        int len = s.length();
        for (int i = 0; i < len; i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < len) {
                char next = s.charAt(i + 1);
                switch (next) {
                    case 'n': sb.append('\n'); i++; break;
                    case 'r': sb.append('\r'); i++; break;
                    case 't': sb.append('\t'); i++; break;
                    case 'b': sb.append('\b'); i++; break;
                    case 'f': sb.append('\f'); i++; break;
                    case '"': sb.append('"'); i++; break;
                    case '\\': sb.append('\\'); i++; break;
                    case '/': sb.append('/'); i++; break;
                    case 'u':
                        if (i + 5 < len) {
                            try {
                                String hex = s.substring(i + 2, i + 6);
                                sb.append((char) Integer.parseInt(hex, 16));
                                i += 5;
                            } catch (Exception ex) {
                                sb.append(c);
                            }
                        } else {
                            sb.append(c);
                        }
                        break;
                    default:
                        sb.append(next);
                        i++;
                        break;
                }
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
