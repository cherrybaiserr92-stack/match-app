package com.example.sdvig.model;

public class CaseItem {
    private String id;
    private CaseType type;
    private String typeLabel;
    private String content;
    private int totalVotes = 0;
    private int leftVotes = 0;
    private int rightVotes = 0;

    public CaseItem() {}

    public CaseItem(String id, CaseType type, String typeLabel, String content) {
        this.id = id;
        this.type = type;
        this.typeLabel = typeLabel;
        this.content = content;
    }

    public synchronized void addVote(String direction) {
        totalVotes++;
        if ("left".equals(direction)) leftVotes++;
        else if ("right".equals(direction)) rightVotes++;
    }

    public int getLeftPercent() {
        return totalVotes == 0 ? 0 : (int) Math.round((double) leftVotes / totalVotes * 100);
    }

    public int getRightPercent() {
        return totalVotes == 0 ? 0 : (int) Math.round((double) rightVotes / totalVotes * 100);
    }

    public String getId() { return id; }
    public CaseType getType() { return type; }
    public String getTypeLabel() { return typeLabel; }
    public String getContent() { return content; }
    public int getTotalVotes() { return totalVotes; }
}
