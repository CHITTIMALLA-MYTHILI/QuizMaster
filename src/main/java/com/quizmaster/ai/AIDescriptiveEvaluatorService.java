package com.quizmaster.ai;

import com.quizmaster.dao.DescriptiveDAO;
import com.quizmaster.model.DescriptiveEvaluation;
import com.quizmaster.model.DescriptiveQuestion;

public class AIDescriptiveEvaluatorService {

    private final LLMClient llmClient = new LLMClient();
    private final DescriptiveDAO descriptiveDAO = new DescriptiveDAO();

    public DescriptiveEvaluation evaluateStudentAnswer(int descQuestionId, int studentId, int attemptId,
                                                      String studentAnswer) throws Exception {

        DescriptiveQuestion dq = descriptiveDAO.getQuestionById(descQuestionId);
        if (dq == null) {
            throw new IllegalArgumentException("Question not found.");
        }

        String systemPrompt = "You are an automated academic examiner evaluating descriptive exam answers.\n" +
                "Evaluate the student's answer strictly against the rubric and expected concepts.\n" +
                "Format output strictly using these labels:\n" +
                "AWARDED_MARKS: (Integer between 0 and " + dq.getMaxMarks() + ")\n" +
                "CONCEPTS_IDENTIFIED: (Bullet points of expected concepts correctly mentioned)\n" +
                "MISSING_CONCEPTS: (Concepts missing from student answer)\n" +
                "FEEDBACK: (Constructive criteria-based evaluation summary)\n" +
                "SUGGESTIONS: (Key improvements for higher scores)";

        StringBuilder userPrompt = new StringBuilder();
        userPrompt.append("Question: ").append(dq.getQuestionText()).append("\n");
        userPrompt.append("Maximum Marks: ").append(dq.getMaxMarks()).append("\n");
        if (dq.getReferenceAnswer() != null) userPrompt.append("Reference Answer: ").append(dq.getReferenceAnswer()).append("\n");
        if (dq.getRubric() != null) userPrompt.append("Marking Rubric: ").append(dq.getRubric()).append("\n");
        if (dq.getExpectedConcepts() != null) userPrompt.append("Expected Concepts: ").append(dq.getExpectedConcepts()).append("\n");
        userPrompt.append("Student Answer: ").append(studentAnswer).append("\n");

        String rawResponse = llmClient.generateCompletion(systemPrompt, userPrompt.toString());

        int awarded = parseAwardedMarks(rawResponse, dq.getMaxMarks());
        String concepts = extractSection(rawResponse, "CONCEPTS_IDENTIFIED:", "MISSING_CONCEPTS:");
        String missing = extractSection(rawResponse, "MISSING_CONCEPTS:", "FEEDBACK:");
        String feedback = extractSection(rawResponse, "FEEDBACK:", "SUGGESTIONS:");
        String suggestions = extractSection(rawResponse, "SUGGESTIONS:", "END");

        DescriptiveEvaluation eval = new DescriptiveEvaluation();
        eval.setDescQuestionId(descQuestionId);
        eval.setStudentId(studentId);
        eval.setAttemptId(attemptId);
        eval.setStudentAnswer(studentAnswer);
        eval.setAwardedMarks(awarded);
        eval.setCriterionFeedback(feedback.isEmpty() ? rawResponse : feedback);
        eval.setConceptsIdentified(concepts);
        eval.setMissingConcepts(missing);
        eval.setSuggestions(suggestions);
        eval.setAdminOverridden(false);

        descriptiveDAO.saveEvaluation(eval);
        return eval;
    }

    private int parseAwardedMarks(String raw, int maxMarks) {
        try {
            int idx = raw.indexOf("AWARDED_MARKS:");
            if (idx != -1) {
                String sub = raw.substring(idx + "AWARDED_MARKS:".length()).trim();
                String[] tokens = sub.split("\\s+");
                int score = Integer.parseInt(tokens[0].replaceAll("[^0-9]", ""));
                return Math.max(0, Math.min(score, maxMarks));
            }
        } catch (Exception ignored) {}
        return 0;
    }

    private String extractSection(String raw, String startMarker, String endMarker) {
        int start = raw.indexOf(startMarker);
        if (start == -1) return "";
        start += startMarker.length();

        int end = (endMarker.equals("END")) ? raw.length() : raw.indexOf(endMarker, start);
        if (end == -1) end = raw.length();

        return raw.substring(start, end).trim();
    }
}
