package com.fluid.afm.markdown.list;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.MDLogger;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.AbstractMarkwonPlugin;

public class DefinitionListPlugin extends AbstractMarkwonPlugin {
    private static final String TAG = "DefinitionListPlugin";
    private static final Pattern TABLE_PATTERN = Pattern.compile("\\|[ \\t]*:?-+:?[ \\t]*(\\|[ \\t]*:?-+:?[ \\t]*)*(\\|$)?", Pattern.MULTILINE);

    @Override
    public String processMarkdown(@NonNull String markdown) {
        long startTime = System.currentTimeMillis();
        if (!markdown.contains(":")) {
            return markdown;
        }
        
        if (hasMarkdownTable(markdown)) {
            return markdown;
        }
        
        if (!hasDefinitionList(markdown)) {
            return markdown;
        }
        return processDefinitionList(markdown, startTime);
    }

    private boolean hasDefinitionList(String markdown) {
        int length = markdown.length();
        boolean newLine = true;
        boolean hasTerm = false;
        
        for (int i = 0; i < length; i++) {
            char c = markdown.charAt(i);
            
            if (c == '\n') {
                newLine = true;
                continue;
            }
            
            if (newLine && (c == ' ' || c == '\t')) {
                continue;
            }
            
            if (newLine && c == ':') {
                if (hasTerm) {
                    return true;
                }
            } else if (newLine) {
                hasTerm = true;
            }
            
            newLine = false;
        }
        
        return false;
    }

    private String processDefinitionList(String markdown, long startTime) {
        StringBuilder result = new StringBuilder(markdown.length() + 100);
        String[] lines = markdown.split("\n");
        
        int i = 0;
        boolean lastWasDefinitionList = false;
        
        while (i < lines.length) {
            int start = findDefinitionListStart(lines, i);
            if (start == -1) {
                for (int j = i; j < lines.length; j++) {
                    result.append(lines[j]).append('\n');
                }
                break;
            }
            for (int j = i; j < start; j++) {
                result.append(lines[j]).append('\n');
                lastWasDefinitionList = false;
            }
            int end = findDefinitionListEnd(lines, start);
            if (lastWasDefinitionList && start > i) {
                result.append('\n');
            }

            processDefinitionListSection(lines, start, end, result);
            lastWasDefinitionList = true;
            
            i = end + 1;
            
            if (i < lines.length && !lines[i].trim().isEmpty()) {
                result.append('\n');
            }
        }
        MDLogger.i(TAG,"processDefinitionList cost: " + (System.currentTimeMillis() - startTime));
        return result.toString();
    }
    private int findDefinitionListEnd(String[] lines, int startIndex) {
        boolean inDefinitionList = false;
        
        for (int i = startIndex; i < lines.length; i++) {
            String line = lines[i].trim();
            
            if (isOtherMarkdownFormat(line)) {
                return i - 1;
            }
            
            if (line.isEmpty()) {
                if (inDefinitionList && (i + 1 >= lines.length || !isDefinitionListLine(lines[i+1]))) {
                    return i - 1;
                }
                continue;
            }
            
            if (!isDefinitionListLine(line) && inDefinitionList) {
                return i - 1;
            }
            
            if (!line.startsWith(":")) {
                if (i + 1 >= lines.length || !lines[i + 1].trim().startsWith(":")) {
                    if (inDefinitionList) {
                        return i - 1;
                    }
                } else {
                    inDefinitionList = true;
                }
            } else {
                inDefinitionList = true;
            }
        }
        
        return lines.length - 1;
    }

    private boolean isDefinitionListLine(String line) {
        line = line.trim();
        if (line.startsWith(":")) {
            return true;
        }
        return !isOtherMarkdownFormat(line);
    }

    private boolean isOtherMarkdownFormat(String line) {
        return isMarkdownHeader(line) || isMarkdownList(line) || 
               isCodeBlock(line) || isHorizontalRule(line);
    }

    private int findDefinitionListStart(String[] lines, int startIndex) {
        for (int i = startIndex; i < lines.length - 1; i++) {
            String line = lines[i].trim();
            String nextLine = lines[i + 1].trim();
            
            if (!line.isEmpty() && nextLine.startsWith(":") &&
                !isOtherMarkdownFormat(line)) {
                return i;
            }
        }
        return -1;
    }

    private void processDefinitionListSection(String[] lines, int start, int end, StringBuilder result) {
        result.append("<dl>\n");
        
        for (int i = start; i <= end; i++) {
            String line = lines[i].trim();
            
            if (line.isEmpty()) {
                continue;
            }
            
            if (line.startsWith(":")) {
                String definition = line.substring(1);
                
                String trimmedDefinition = definition.trim();
                if (!trimmedDefinition.isEmpty()) {
                    result.append("  <dd>").append(trimmedDefinition).append("</dd>\n");
                }
            } else if (i + 1 <= end && lines[i + 1].trim().startsWith(":")) {
                result.append("  <dt>").append(line).append("</dt>\n");
            } else {
                result.append(lines[i]).append('\n');
            }
        }
        
        result.append("</dl>\n");
    }

    private boolean isMarkdownHeader(String line) {
        return line.startsWith("#") || line.startsWith("=====") || line.startsWith("-----");
    }

    private boolean isMarkdownList(String line) {
        return line.matches("^\\s*[-*+]\\s+.*") || line.matches("^\\s*\\d+\\.\\s+.*");
    }

    private boolean isCodeBlock(String line) {
        return line.startsWith("```") || line.startsWith("    ") || line.startsWith("\t");
    }

    private boolean isHorizontalRule(String line) {
        return line.matches("^\\s*(\\*\\s*){3,}$") || line.matches("^\\s*(-\\s*){3,}$") || line.matches("^\\s*(_\\s*){3,}$");
    }

    private boolean hasMarkdownTable(String markdown) {
        if (TextUtils.isEmpty(markdown)) {
            return false;
        }

        try {
            Matcher matcher = TABLE_PATTERN.matcher(markdown);
            return matcher.find();
        } catch (Throwable e) {
            MDLogger.e(TAG,  e);
            return false;
        }
    }

    public static DefinitionListPlugin create() {
        return new DefinitionListPlugin();
    }
} 