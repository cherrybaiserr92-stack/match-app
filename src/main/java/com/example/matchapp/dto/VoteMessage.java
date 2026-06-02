package com.example.matchapp.dto;

public class VoteMessage {
    private String caseId;
    private String userId;
    private String direction; // "left" или "right"

    public VoteMessage() {}
    public String getCaseId() { return caseId; }
    public void setCaseId(String caseId) { this.caseId = caseId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }
}
