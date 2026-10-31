package com.quizmaster.ai;

import com.quizmaster.dao.AIQuestionDraftDAO;
import com.quizmaster.model.AIQuestionDraft;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AIQuizGeneratorService {

    private final LLMClient llmClient = new LLMClient();
    private final AIQuestionDraftDAO draftDAO = new AIQuestionDraftDAO();

    public String generateQuizDrafts(String topic, String studyMaterial, int numQuestions,
                                     String difficulty, int marksPerQuestion) throws Exception {

        String batchId = UUID.randomUUID().toString().substring(0, 8);

        String systemPrompt = "You are an expert exam question creator. You generate multiple-choice questions in strict format.\n" +
                "Output each question starting with 'QUESTION:' on its own line.\n" +
                "Followed by OPTION_A:, OPTION_B:, OPTION_C:, OPTION_D:\n" +
                "Followed by CORRECT: (A, B, C, or D)\n" +
                "Followed by EXPLANATION: (brief reason why it is correct)\n" +
                "Do not include any other markdown formatting or conversational text.";

        StringBuilder userPrompt = new StringBuilder();
        userPrompt.append("Generate exactly ").append(numQuestions).append(" multiple-choice questions.\n");
        userPrompt.append("Topic: ").append(topic).append("\n");
        userPrompt.append("Difficulty: ").append(difficulty).append("\n");
        if (studyMaterial != null && !studyMaterial.trim().isEmpty()) {
            userPrompt.append("Base the questions primarily on this study material text:\n")
                      .append(studyMaterial.length() > 4000 ? studyMaterial.substring(0, 4000) : studyMaterial)
                      .append("\n");
        }

        String rawResponse = llmClient.generateCompletion(systemPrompt, userPrompt.toString());
        List<AIQuestionDraft> parsedDrafts = parseQuestions(rawResponse, batchId, topic, difficulty, marksPerQuestion);

        if (parsedDrafts.isEmpty()) {
            throw new RuntimeException("AI response could not be parsed into valid questions. Please try again.");
        }

        for (AIQuestionDraft draft : parsedDrafts) {
            draftDAO.saveDraft(draft);
        }

        return batchId;
    }

    private List<AIQuestionDraft> parseQuestions(String raw, String batchId, String topic,
                                                String difficulty, int marks) {
        List<AIQuestionDraft> list = new ArrayList<>();
        String[] blocks = raw.split("(?i)(?=QUESTION:)");

        for (String block : blocks) {
            if (!block.toUpperCase().contains("QUESTION:")) continue;

            String qText = extractField(block, "QUESTION:");
            String optA = extractField(block, "OPTION_A:");
            String optB = extractField(block, "OPTION_B:");
            String optC = extractField(block, "OPTION_C:");
            String optD = extractField(block, "OPTION_D:");
            String correct = extractField(block, "CORRECT:").replaceAll("[^A-Da-d]", "").toUpperCase();
            String explanation = extractField(block, "EXPLANATION:");

            if (qText != null && !qText.isEmpty() && optA != null && optB != null &&
                    optC != null && optD != null && !correct.isEmpty()) {

                AIQuestionDraft d = new AIQuestionDraft();
                d.setBatchId(batchId);
                d.setTopic(topic);
                d.setQuestionText(qText);
                d.setOptionA(optA);
                d.setOptionB(optB);
                d.setOptionC(optC);
                d.setOptionD(optD);
                d.setCorrectOption(correct.substring(0, 1));
                d.setMarks(marks);
                d.setDifficulty(difficulty);
                d.setExplanation(explanation != null ? explanation : "");
                list.add(d);
            }
        }
        return list;
    }

    private String extractField(String block, String prefix) {
        int start = block.toUpperCase().indexOf(prefix);
        if (start == -1) return "";
        start += prefix.length();

        int end = block.length();
        String[] nextMarkers = {"OPTION_A:", "OPTION_B:", "OPTION_C:", "OPTION_D:", "CORRECT:", "EXPLANATION:", "QUESTION:"};
        for (String marker : nextMarkers) {
            if (marker.equalsIgnoreCase(prefix)) continue;
            int pos = block.toUpperCase().indexOf(marker, start);
            if (pos != -1 && pos < end) {
                end = pos;
            }
        }
        return block.substring(start, end).trim();
    }
}
