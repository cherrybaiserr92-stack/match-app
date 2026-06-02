package com.example.matchapp.model;

import java.util.concurrent.atomic.AtomicInteger;

public class CaseItem {
    private String id;
    private CaseType type;
    private String title;
    private String content;
    
    // AtomicInteger защищает от сбоев, если 1000 человек проголосуют в одну миллисекунду
    private AtomicInteger votesLeft = new AtomicInteger(0);
    private AtomicInteger votesRight = new AtomicInteger(0);

    public CaseItem(String id, CaseType type, String title, String content) {
        this.id = id;
        this.type = type;
        this.title = title;
        this.content = content;
        // Симулируем стартовые голоса, чтобы графики не были нулевыми при запуске
        this.votesLeft.set((int)(Math.random() * 50) + 10);
        this.votesRight.set((int)(Math.random() * 50) + 10);
    }

    public void addVote(String direction) {
        if ("left".equals(direction)) votesLeft.incrementAndGet();
        else if ("right".equals(direction)) votesRight.incrementAndGet();
    }

    public int getTotalVotes() { return votesLeft.get() + votesRight.get(); }
    
    public int getLeftPercent() {
        int total = getTotalVotes();
        return total == 0 ? 50 : (int) Math.round((votesLeft.get() * 100.0) / total);
    }

    public int getRightPercent() {
        int total = getTotalVotes();
        return total == 0 ? 50 : 100 - getLeftPercent();
    }
    
    public String getId() { return id; }
    public CaseType getType() { return type; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
}
