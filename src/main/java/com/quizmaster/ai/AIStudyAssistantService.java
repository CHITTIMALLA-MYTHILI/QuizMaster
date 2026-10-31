package com.quizmaster.ai;

import com.quizmaster.model.StudentPracticeQuestion;

import java.util.ArrayList;
import java.util.List;

public class AIStudyAssistantService {

    private static final int MAX_TEXT_CHARS = 4000;
    private final LLMClient llmClient = new LLMClient();

    public String generateSummary(String materialText, String summaryType) throws Exception {
        if (materialText == null || materialText.trim().length() < 20) {
            throw new IllegalArgumentException("Study material is too short to generate a meaningful summary (minimum 20 characters required).");
        }

        String processedText = prepareStudyText(materialText);

        String systemPrompt = "You are QuizMaster AI Study Assistant, an expert academic tutor. " +
                "Produce a structured, comprehensive educational summary based strictly on the provided material. " +
                "Never invent facts not present in or strongly implied by the supplied material. " +
                "Use clean Markdown headings (##, ###) and bullet points.";

        String typeInstructions;
        switch (summaryType != null ? summaryType.toLowerCase() : "quick") {
            case "detailed":
                typeInstructions = "Generate a DETAILED SUMMARY with comprehensive coverage of all major topics, principles, in-depth explanations, and context.";
                break;
            case "revision":
                typeInstructions = "Generate EXAM REVISION NOTES focused on high-yield exam takeaways, key bullet points, must-remember facts, and common exam pitfalls.";
                break;
            case "concepts":
                typeInstructions = "Generate an IMPORTANT CONCEPTS AND DEFINITIONS list. Bold every term followed by a concise definition and practical example.";
                break;
            case "formulas":
                typeInstructions = "Generate a FORMULAS AND KEY PRINCIPLES sheet. Highlight all mathematical or scientific formulas, laws, theorems, and core procedural rules.";
                break;
            case "chapters":
                typeInstructions = "Generate a CHAPTER / TOPIC-WISE OUTLINE with numbered sections, sub-topics, and structured summaries under each heading.";
                break;
            case "quick":
            default:
                typeInstructions = "Generate a QUICK EXECUTIVE SUMMARY with an overview paragraph, 5 to 8 essential bullet takeaways, and a conclusion.";
                break;
        }

        String userPrompt = typeInstructions + "\n\n=== SOURCE STUDY MATERIAL ===\n" + processedText;

        return llmClient.generateCompletion(systemPrompt, userPrompt);
    }

    public List<StudentPracticeQuestion> generatePracticeQuiz(String materialText, int numQuestions,
                                                             String difficulty, String questionType) throws Exception {
        if (materialText == null || materialText.trim().length() < 20) {
            throw new IllegalArgumentException("Study material is too short to generate practice questions (minimum 20 characters required).");
        }

        // Validate number of questions (5, 10, 15, 20)
        if (numQuestions <= 0) numQuestions = 5;
        if (numQuestions > 20) numQuestions = 20;

        String processedText = prepareStudyText(materialText);

        String typeGuidance;
        if ("True/False".equalsIgnoreCase(questionType)) {
            typeGuidance = "Generate True/False questions only. For each question, OPTION_A must be 'True', OPTION_B must be 'False', OPTION_C can be '-', OPTION_D can be '-'. CORRECT must be either A or B.";
        } else if ("Mixed".equalsIgnoreCase(questionType)) {
            typeGuidance = "Generate a mix of 4-option Multiple Choice Questions and True/False questions based on the content.";
        } else {
            typeGuidance = "Generate 4-option Multiple Choice Questions (A, B, C, D) with exactly one correct option.";
        }

        String systemPrompt = "You are an expert exam designer. " +
                "Create high-quality practice quiz questions strictly based on the provided study material. " +
                typeGuidance + "\n\n" +
                "CRITICAL: Output EACH question strictly following this exact format:\n\n" +
                "QUESTION: <question text>\n" +
                "OPTION_A: <option A>\n" +
                "OPTION_B: <option B>\n" +
                "OPTION_C: <option C>\n" +
                "OPTION_D: <option D>\n" +
                "CORRECT: <A, B, C, or D>\n" +
                "EXPLANATION: <concise explanation of why this is correct based on the material>\n\n" +
                "Do not include any other markdown headers, numbering, or conversational text.";

        String userPrompt = "Generate exactly " + numQuestions + " questions at difficulty level '" + difficulty + "'.\n\n" +
                "=== STUDY MATERIAL ===\n" + processedText;

        String rawResponse = llmClient.generateCompletion(systemPrompt, userPrompt);
        List<StudentPracticeQuestion> questions = parsePracticeQuestions(rawResponse);

        if (questions.isEmpty()) {
            throw new RuntimeException("Could not extract valid practice questions from AI response. Please try with more specific text or lower question count.");
        }

        return questions;
    }

    private String prepareStudyText(String text) {
        String trimmed = text.trim();
        if (trimmed.length() <= MAX_TEXT_CHARS) {
            return trimmed;
        }

        // Truncate cleanly at paragraph or sentence boundary
        int cutIndex = trimmed.lastIndexOf("\n", MAX_TEXT_CHARS);
        if (cutIndex < MAX_TEXT_CHARS / 2) {
            cutIndex = trimmed.lastIndexOf(". ", MAX_TEXT_CHARS);
        }
        if (cutIndex < MAX_TEXT_CHARS / 2) {
            cutIndex = MAX_TEXT_CHARS;
        }

        String chunk = trimmed.substring(0, cutIndex).trim();
        return chunk + "\n\n[Note: Excerpt limited to the first " + chunk.length() + " characters for fast, targeted quiz synthesis.]";
    }

    private List<StudentPracticeQuestion> parsePracticeQuestions(String raw) {
        List<StudentPracticeQuestion> list = new ArrayList<>();
        if (raw == null || raw.isEmpty()) return list;

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

            // Clean options
            if (optC.isEmpty()) optC = "-";
            if (optD.isEmpty()) optD = "-";

            if (!qText.isEmpty() && !optA.isEmpty() && !optB.isEmpty() && !correct.isEmpty()) {
                StudentPracticeQuestion q = new StudentPracticeQuestion();
                q.setQuestionText(qText);
                q.setOptionA(optA);
                q.setOptionB(optB);
                q.setOptionC(optC);
                q.setOptionD(optD);
                q.setCorrectOption(correct.substring(0, 1));
                q.setExplanation(explanation != null && !explanation.isEmpty() ? explanation : "Refer to study material.");
                list.add(q);
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
