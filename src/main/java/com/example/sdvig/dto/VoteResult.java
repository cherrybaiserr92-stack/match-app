package com.example.sdvig.dto;

public class VoteResult {
    private String caseId;
    private int totalVotes;
    private int leftPercent;
    private int rightPercent;

    public VoteResult(String caseId, int totalVotes, int leftPercent, int rightPercent) {
        this.caseId = caseId;
        this.totalVotes = totalVotes;
        this.leftPercent = leftPercent;
        this.rightPercent = rightPercent;
    }

    public String getCaseId() { return caseId; }
    public int getTotalVotes() { return totalVotes; }
    public int getLeftPercent() { return leftPercent; }
    public int getRightPercent() { return rightPercent; }
}
