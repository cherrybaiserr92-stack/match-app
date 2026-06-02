package com.example.matchapp.dto;

public class SwipeMessage {
    private String roomId;    // Номер комнаты
    private String userId;    // ID пользователя
    private int itemId;       // ID карточки (еды/фильма)
    private String direction; // "right" (лайк) или "left" (дизлайк)

    // Пустой конструктор (нужен для Spring)
    public SwipeMessage() {}

    public String getRoomId() { return roomId; }
    public void setRoomId(String roomId) { this.roomId = roomId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }
}
