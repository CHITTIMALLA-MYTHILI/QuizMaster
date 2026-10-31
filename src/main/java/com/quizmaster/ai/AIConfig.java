package com.quizmaster.ai;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class AIConfig {

    private static final String DEFAULT_PROVIDER = "gemini";
    private static final String DEFAULT_MODEL = "gemini-1.5-flash";
    private static final int DEFAULT_TIMEOUT_SECONDS = 35;

    private static String apiKey;
    private static String provider;
    private static String model;
    private static int timeoutSeconds = DEFAULT_TIMEOUT_SECONDS;

    static {
        loadConfiguration();
    }

    public static synchronized void loadConfiguration() {
        // Priority 1: Environment variable
        apiKey = System.getenv("QUIZMASTER_AI_API_KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = System.getenv("GEMINI_API_KEY");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = System.getenv("OPENAI_API_KEY");
        }

        // Priority 2: System properties
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = System.getProperty("QUIZMASTER_AI_API_KEY");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = System.getProperty("quizmaster.ai.api.key");
        }

        // Priority 3: ai.properties file in classpath
        if (apiKey == null || apiKey.trim().isEmpty()) {
            try (InputStream is = AIConfig.class.getClassLoader().getResourceAsStream("ai.properties")) {
                if (is != null) {
                    Properties props = new Properties();
                    props.load(is);
                    String fileKey = props.getProperty("quizmaster.ai.api.key");
                    if (fileKey != null && !fileKey.trim().isEmpty() && !fileKey.contains("YOUR_API_KEY")) {
                        apiKey = fileKey.trim();
                    }
                    if (provider == null) provider = props.getProperty("quizmaster.ai.provider");
                    if (model == null) model = props.getProperty("quizmaster.ai.model");
                }
            } catch (Exception ignored) {
            }
        }

        // Auto-detect provider if key starts with sk- (OpenAI format)
        if (apiKey != null && apiKey.trim().startsWith("sk-")) {
            if (provider == null || DEFAULT_PROVIDER.equalsIgnoreCase(provider)) {
                provider = "openai";
                if (model == null || DEFAULT_MODEL.equalsIgnoreCase(model)) {
                    model = "gpt-4o-mini";
                }
            }
        }

        if (provider == null || provider.trim().isEmpty()) {
            provider = System.getenv("QUIZMASTER_AI_PROVIDER");
            if (provider == null || provider.trim().isEmpty()) {
                provider = DEFAULT_PROVIDER;
            }
        }

        if (model == null || model.trim().isEmpty()) {
            model = System.getenv("QUIZMASTER_AI_MODEL");
            if (model == null || model.trim().isEmpty()) {
                model = DEFAULT_MODEL;
            }
        }

        timeoutSeconds = DEFAULT_TIMEOUT_SECONDS;
    }

    public static boolean isConfigured() {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            loadConfiguration();
        }
        return apiKey != null && !apiKey.trim().isEmpty();
    }

    public static String getApiKey() {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            loadConfiguration();
        }
        return apiKey != null ? apiKey.trim() : null;
    }

    public static String getProvider() {
        if (provider == null) {
            loadConfiguration();
        }
        return provider;
    }

    public static String getModel() {
        if (model == null) {
            loadConfiguration();
        }
        return model;
    }

    public static int getTimeoutSeconds() {
        return timeoutSeconds;
    }
}
