package io.noties.markwon.node;
import org.commonmark.node.CustomNode;

public class OiintNode extends CustomNode {
    private String integrationLimit;
    public void setIntegrationLimit(String limit) {
        this.integrationLimit = limit;
    }
    public String getIntegrationLimit() {
        return integrationLimit;
    }
}