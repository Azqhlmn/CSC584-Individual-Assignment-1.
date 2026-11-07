package com.ehadir.bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class Registration implements Serializable {

    private int regId;
    private int eventId;
    private String ticketCode;
    private Timestamp regDate;
    private String attendanceStatus;
    private String eventTitle;
    private String venue;
    private Timestamp eventDate;
    private String clubName;
    private boolean canCancel;

    public Registration() {
    }

    public int getRegId() { return regId; }
    public void setRegId(int regId) { this.regId = regId; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public String getTicketCode() { return ticketCode; }
    public void setTicketCode(String ticketCode) { this.ticketCode = ticketCode; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }

    public String getAttendanceStatus() { return attendanceStatus; }
    public void setAttendanceStatus(String attendanceStatus) { this.attendanceStatus = attendanceStatus; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }

    public Timestamp getEventDate() { return eventDate; }
    public void setEventDate(Timestamp eventDate) { this.eventDate = eventDate; }

    public String getClubName() { return clubName; }
    public void setClubName(String clubName) { this.clubName = clubName; }

    public boolean isCanCancel() { return canCancel; }
    public void setCanCancel(boolean canCancel) { this.canCancel = canCancel; }
    
    
    private String studentName;
    private String studentId;

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
}

