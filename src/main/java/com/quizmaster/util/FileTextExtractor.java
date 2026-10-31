package com.quizmaster.util;

import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.Inflater;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class FileTextExtractor {

    public static class ExtractionResult {
        private final String text;
        private final String fileName;
        private final String fileType;

        public ExtractionResult(String text, String fileName, String fileType) {
            this.text = text;
            this.fileName = fileName;
            this.fileType = fileType;
        }

        public String getText() {
            return text;
        }

        public String getFileName() {
            return fileName;
        }

        public String getFileType() {
            return fileType;
        }
    }

    public static ExtractionResult extractText(Part part) throws Exception {
        if (part == null || part.getSize() == 0) {
            throw new IllegalArgumentException("Uploaded file is empty.");
        }

        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            submittedFileName = "uploaded_file";
        }

        String lowerName = submittedFileName.toLowerCase();
        String fileType;
        String text;

        if (lowerName.endsWith(".txt")) {
            fileType = "TXT";
            text = extractFromTxt(part.getInputStream());
        } else if (lowerName.endsWith(".docx")) {
            fileType = "DOCX";
            text = extractFromDocx(part.getInputStream());
        } else if (lowerName.endsWith(".pdf")) {
            fileType = "PDF";
            text = extractFromPdf(part.getInputStream());
        } else {
            throw new IllegalArgumentException("Unsupported file type. Only .pdf, .docx, and .txt files are allowed.");
        }

        if (text == null || text.trim().length() < 15) {
            if ("PDF".equals(fileType)) {
                throw new IllegalStateException("No extractable text found in this PDF. Scanned PDFs or image-only documents require OCR. Please copy-paste the text directly into the study material text area.");
            } else {
                throw new IllegalStateException("No meaningful text could be extracted from " + submittedFileName + ". Please check the file or paste the text directly.");
            }
        }

        return new ExtractionResult(text.trim(), submittedFileName, fileType);
    }

    private static String extractFromTxt(InputStream is) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int read;
        while ((read = is.read(buffer)) != -1) {
            baos.write(buffer, 0, read);
        }
        byte[] bytes = baos.toByteArray();
        // Try UTF-8 first
        String content = new String(bytes, StandardCharsets.UTF_8);
        return cleanText(content);
    }

    private static String extractFromDocx(InputStream is) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (ZipInputStream zis = new ZipInputStream(is)) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                if ("word/document.xml".equalsIgnoreCase(entry.getName())) {
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[8192];
                    int read;
                    while ((read = zis.read(buffer)) != -1) {
                        baos.write(buffer, 0, read);
                    }
                    String xml = baos.toString(StandardCharsets.UTF_8);
                    sb.append(parseDocxXml(xml));
                    break;
                }
            }
        }
        return cleanText(sb.toString());
    }

    private static String parseDocxXml(String xml) {
        StringBuilder out = new StringBuilder();
        // Replace paragraph endings with newlines
        String normalized = xml.replaceAll("</w:p>", "\n")
                               .replaceAll("<w:br/>", "\n")
                               .replaceAll("<w:cr/>", "\n");

        Pattern textPattern = Pattern.compile("<w:t[^>]*>(.*?)</w:t>");
        Matcher matcher = textPattern.matcher(normalized);
        int lastEnd = 0;
        while (matcher.find()) {
            int start = matcher.start();
            String gap = normalized.substring(lastEnd, start);
            if (gap.contains("\n")) {
                out.append("\n");
            }
            String val = matcher.group(1);
            // unescape standard XML entities
            val = val.replace("&amp;", "&")
                     .replace("&lt;", "<")
                     .replace("&gt;", ">")
                     .replace("&quot;", "\"")
                     .replace("&apos;", "'");
            out.append(val);
            lastEnd = matcher.end();
        }
        return out.toString();
    }

    private static String extractFromPdf(InputStream is) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int read;
        while ((read = is.read(buffer)) != -1) {
            baos.write(buffer, 0, read);
        }
        byte[] pdfBytes = baos.toByteArray();

        StringBuilder extractedText = new StringBuilder();

        // 1. Scan for stream blocks in PDF
        int pos = 0;
        int len = pdfBytes.length;
        byte[] streamMarker = "stream".getBytes(StandardCharsets.US_ASCII);
        byte[] endStreamMarker = "endstream".getBytes(StandardCharsets.US_ASCII);

        while (pos < len) {
            int streamStart = findSubarray(pdfBytes, streamMarker, pos);
            if (streamStart == -1) break;

            int dataStart = streamStart + streamMarker.length;
            // Skip CRLF
            if (dataStart < len && pdfBytes[dataStart] == '\r') dataStart++;
            if (dataStart < len && pdfBytes[dataStart] == '\n') dataStart++;

            int streamEnd = findSubarray(pdfBytes, endStreamMarker, dataStart);
            if (streamEnd == -1) break;

            // Trim any preceding CRLF before endstream
            int dataEnd = streamEnd;
            if (dataEnd > dataStart && pdfBytes[dataEnd - 1] == '\n') dataEnd--;
            if (dataEnd > dataStart && pdfBytes[dataEnd - 1] == '\r') dataEnd--;

            byte[] streamData = new byte[dataEnd - dataStart];
            System.arraycopy(pdfBytes, dataStart, streamData, 0, streamData.length);

            // Attempt to decompress stream (FlateDecode)
            byte[] decompressed = null;
            try {
                decompressed = decompressZlib(streamData);
            } catch (Exception ignored) {
            }

            if (decompressed != null && decompressed.length > 0) {
                parsePdfStreamContent(new String(decompressed, StandardCharsets.ISO_8859_1), extractedText);
            } else {
                parsePdfStreamContent(new String(streamData, StandardCharsets.ISO_8859_1), extractedText);
            }

            pos = streamEnd + endStreamMarker.length;
        }

        // Also check if text was stored directly in uncompressed strings outside stream
        if (extractedText.length() < 30) {
            parsePdfStreamContent(new String(pdfBytes, StandardCharsets.ISO_8859_1), extractedText);
        }

        return cleanText(extractedText.toString());
    }

    private static void parsePdfStreamContent(String content, StringBuilder out) {
        if (content == null || content.isEmpty()) return;

        // Match BT (begin text) ... ET (end text) blocks
        Pattern textBlockPattern = Pattern.compile("BT\\s+(.*?)\\s+ET", Pattern.DOTALL);
        Matcher blockMatcher = textBlockPattern.matcher(content);

        boolean foundBlock = false;
        while (blockMatcher.find()) {
            foundBlock = true;
            String block = blockMatcher.group(1);
            extractPdfTextOperators(block, out);
            out.append("\n");
        }

        // If no BT..ET blocks found, try matching literal strings like (Hello) Tj
        if (!foundBlock) {
            extractPdfTextOperators(content, out);
        }
    }

    private static void extractPdfTextOperators(String block, StringBuilder out) {
        // Match (text) Tj, (text) ' , [(text) (more)] TJ
        Pattern tjPattern = Pattern.compile("\\(([^()]*)\\)\\s*(?:Tj|'|\")");
        Matcher tjMatcher = tjPattern.matcher(block);
        while (tjMatcher.find()) {
            String s = tjMatcher.group(1);
            out.append(unescapePdfString(s)).append(" ");
        }

        // Match TJ array: [ ... ] TJ
        Pattern tjArrayPattern = Pattern.compile("\\[(.*?)\\]\\s*TJ", Pattern.DOTALL);
        Matcher tjArrayMatcher = tjArrayPattern.matcher(block);
        while (tjArrayMatcher.find()) {
            String arrayContent = tjArrayMatcher.group(1);
            Matcher strMatcher = Pattern.compile("\\(([^()]*)\\)").matcher(arrayContent);
            while (strMatcher.find()) {
                out.append(unescapePdfString(strMatcher.group(1)));
            }
            out.append(" ");
        }
    }

    private static String unescapePdfString(String s) {
        if (s == null) return "";
        return s.replace("\\(", "(")
                .replace("\\)", ")")
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t")
                .replace("\\\\", "\\");
    }

    private static byte[] decompressZlib(byte[] data) {
        Inflater inflater = new Inflater();
        inflater.setInput(data);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        try {
            while (!inflater.finished()) {
                int count = inflater.inflate(buf);
                if (count == 0) {
                    if (inflater.needsInput() || inflater.needsDictionary()) {
                        break;
                    }
                }
                baos.write(buf, 0, count);
            }
            return baos.toByteArray();
        } catch (Exception e) {
            return null;
        } finally {
            inflater.end();
        }
    }

    private static int findSubarray(byte[] array, byte[] sub, int start) {
        if (array == null || sub == null || start >= array.length || sub.length == 0) return -1;
        for (int i = start; i <= array.length - sub.length; i++) {
            boolean match = true;
            for (int j = 0; j < sub.length; j++) {
                if (array[i + j] != sub[j]) {
                    match = false;
                    break;
                }
            }
            if (match) return i;
        }
        return -1;
    }

    private static String cleanText(String raw) {
        if (raw == null) return "";
        // Remove null characters and replace excessive spaces
        String s = raw.replace("\u0000", "");
        s = s.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
        s = s.replaceAll("[ \t]+", " ");
        s = s.replaceAll("\n{3,}", "\n\n");
        return s.trim();
    }
}
