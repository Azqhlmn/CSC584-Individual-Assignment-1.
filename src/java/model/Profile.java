package model;

public class Profile {

    private int    id;
    private String fullName;
    private String studentId;
    private String program;
    private String email;
    private String hobbies;
    private String bio;
    private String website;
    private String github;
    private String twitter;
    private String instagram;
    private String facebook;
    private int    webDesign;
    private int    webMarkup;
    private int    onePage;
    private int    mobileTemplate;
    private int    backendApi;
    private String photoPath;

    public Profile() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getHobbies() { return hobbies; }
    public void setHobbies(String hobbies) { this.hobbies = hobbies; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getGithub() { return github; }
    public void setGithub(String github) { this.github = github; }

    public String getTwitter() { return twitter; }
    public void setTwitter(String twitter) { this.twitter = twitter; }

    public String getInstagram() { return instagram; }
    public void setInstagram(String instagram) { this.instagram = instagram; }

    public String getFacebook() { return facebook; }
    public void setFacebook(String facebook) { this.facebook = facebook; }

    public int getWebDesign() { return webDesign; }
    public void setWebDesign(int webDesign) { this.webDesign = webDesign; }

    public int getWebMarkup() { return webMarkup; }
    public void setWebMarkup(int webMarkup) { this.webMarkup = webMarkup; }

    public int getOnePage() { return onePage; }
    public void setOnePage(int onePage) { this.onePage = onePage; }

    public int getMobileTemplate() { return mobileTemplate; }
    public void setMobileTemplate(int mobileTemplate) { this.mobileTemplate = mobileTemplate; }

    public int getBackendApi() { return backendApi; }
    public void setBackendApi(int backendApi) { this.backendApi = backendApi; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    public String getInitials() {
        if (fullName == null || fullName.trim().isEmpty()) return "?";
        String[] parts = fullName.trim().split("\\s+");
        StringBuilder sb = new StringBuilder();
        sb.append(Character.toUpperCase(parts[0].charAt(0)));
        if (parts.length > 1)
            sb.append(Character.toUpperCase(parts[1].charAt(0)));
        return sb.toString();
    }
}