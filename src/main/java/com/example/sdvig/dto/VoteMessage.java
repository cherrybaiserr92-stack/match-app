package com.example.sdvig.dto;

public class VoteMessage {
    private String caseId;
    private String direction;

    public String getCaseId() { return caseId; }
    public void setCaseId(String caseId) { this.caseId = caseId; }
    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }
}
