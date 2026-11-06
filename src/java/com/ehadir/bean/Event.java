package com.ehadir.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class Event implements Serializable {

    private int eventId;
    private String title;
    private String description;
    private String venue;
    private Timestamp eventDate;
    private int capacity;
    private String status;
    private String clubName;
    private String categoryName;
    private int registered;
    private boolean registeredByMe;

    public Event() {
    }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }

    public Timestamp getEventDate() { return eventDate; }
    public void setEventDate(Timestamp eventDate) { this.eventDate = eventDate; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getClubName() { return clubName; }
    public void setClubName(String clubName) { this.clubName = clubName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getRegistered() { return registered; }
    public void setRegistered(int registered) { this.registered = registered; }

    public boolean isRegisteredByMe() { return registeredByMe; }
    public void setRegisteredByMe(boolean registeredByMe) { this.registeredByMe = registeredByMe; }

    public int getSeatsLeft() {
        return Math.max(0, capacity - registered);
    }

    public boolean isEnded() {
        return eventDate != null && eventDate.before(new Timestamp(System.currentTimeMillis()));
    }
}