<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Profile"%>
<%
    Profile profile = (Profile) request.getAttribute("profile");
    if (profile == null) {
        response.sendRedirect("index.html");
        return;
    }
    String nameAttr      = profile.getFullName();
    String idAttr        = profile.getStudentId();
    String programAttr   = profile.getProgram();
    String emailAttr     = profile.getEmail();
    String hobbiesAttr   = profile.getHobbies();
    String bioAttr       = profile.getBio();
    String websiteAttr   = profile.getWebsite();
    String githubAttr    = profile.getGithub();
    String twitterAttr   = profile.getTwitter();
    String instagramAttr = profile.getInstagram();
    String facebookAttr  = profile.getFacebook();
    int webDesignVal      = profile.getWebDesign();
    int webMarkupVal      = profile.getWebMarkup();
    int onePageVal        = profile.getOnePage();
    int mobileTemplateVal = profile.getMobileTemplate();
    int backendApiVal     = profile.getBackendApi();
    String initials  = profile.getInitials();
    String photoPath = profile.getPhotoPath();
    boolean hasPhoto = (photoPath != null && !photoPath.trim().isEmpty());
    boolean hasBio   = (bioAttr != null
                        && !bioAttr.trim().isEmpty()
                        && !bioAttr.equals("null"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile — <%= nameAttr %></title>

    <!-- ═══════════════════════════════
         SCREEN STYLES
    ════════════════════════════════ -->
    <style>
        :root {
            --bg:      #09090b;
            --card:    #18181b;
            --border:  rgba(255,255,255,0.08);
            --text:    #f4f4f5;
            --muted:   #a1a1aa;
            --indigo:  #6366f1;
            --emerald: #10b981;
            --amber:   #f59e0b;
            --rose:    #f43f5e;
            --cyan:    #06b6d4;
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 24px 20px 60px;
            min-height: 100vh;
        }

        /* success banner */
        .success-banner {
            max-width: 1200px;
            margin: 0 auto 22px;
            background: linear-gradient(135deg, #059669, #10b981);
            color: #fff;
            padding: 15px 22px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideIn 0.4s ease;
        }
        @keyframes slideIn {
            from { opacity:0; transform:translateY(-8px); }
            to   { opacity:1; transform:translateY(0); }
        }

        /* layout */
        .dashboard {
            max-width: 1200px;
            margin: auto;
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
        }
        @media (min-width: 992px) {
            .dashboard { grid-template-columns: 320px 1fr; }
        }

        /* card */
        .card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 8px 24px -8px rgba(0,0,0,0.4);
            transition: border-color 0.3s, transform 0.3s;
        }
        .card:hover {
            border-color: rgba(255,255,255,0.14);
            transform: translateY(-3px);
        }

        /* avatar */
        .hero {
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .av-wrap { position: relative; margin-bottom: 16px; }
        .av-wrap::before {
            content: '';
            position: absolute;
            inset: -4px;
            background: linear-gradient(135deg, var(--indigo), var(--cyan));
            border-radius: 50%;
            opacity: 0.6;
            filter: blur(8px);
            z-index: 1;
        }
        .av-photo {
            position: relative; z-index: 2;
            width: 100px; height: 100px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--card);
            display: block;
        }
        .av {
            position: relative; z-index: 2;
            width: 100px; height: 100px;
            background: #27272a;
            border: 3px solid var(--card);
            border-radius: 50%;
            display: inline-flex;
            align-items: center; justify-content: center;
            font-size: 32px; font-weight: 800; color: #fff;
        }
        .hero h3 { margin: 0 0 6px; font-size: 20px; font-weight: 700; }
        .prog-badge {
            color: var(--muted); font-size: 12px;
            background: rgba(255,255,255,0.05);
            padding: 4px 12px; border-radius: 100px;
            border: 1px solid var(--border);
            margin-bottom: 16px; display: inline-block;
        }
        .btn-msg {
            display: block; width: 100%; padding: 10px;
            background: linear-gradient(135deg,#4f46e5,#6366f1);
            color: #fff; border: none; border-radius: 10px;
            font-size: 13px; font-weight: 600;
            text-align: center; text-decoration: none;
            box-shadow: 0 4px 14px rgba(99,102,241,0.3);
            transition: opacity 0.2s; cursor: pointer;
        }
        .btn-msg:hover { opacity: 0.9; }

        /* social list */
        .s-list {
            list-style: none; padding: 0; margin: 0;
            display: flex; flex-direction: column; gap: 8px;
        }
        .s-item {
            display: flex; justify-content: space-between;
            align-items: center; padding: 10px 13px;
            background: rgba(255,255,255,0.02);
            border: 1px solid var(--border);
            border-radius: 10px; font-size: 13px;
            transition: background 0.2s;
        }
        .s-item:hover { background: rgba(255,255,255,0.05); }
        .s-label {
            display: flex; align-items: center; gap: 9px;
            color: var(--muted); font-weight: 500;
        }
        .s-label img { width: 14px; height: 14px; }
        .s-val {
            font-weight: 600; font-size: 12px;
            word-break: break-all; text-align: right; max-width: 55%;
        }

        /* pill grid */
        .pill-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        @media (max-width: 576px) { .pill-grid { grid-template-columns: 1fr; } }
        .pill {
            background: rgba(255,255,255,0.02);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 14px;
        }
        .pill-lbl {
            font-size: 10px; text-transform: uppercase;
            letter-spacing: 1px; color: var(--muted);
            font-weight: 700; margin-bottom: 5px;
        }
        .pill-val { font-size: 13px; font-weight: 600; color: var(--text); }

        /* bio */
        .bio-box {
            background: linear-gradient(135deg,
                rgba(99,102,241,0.05), rgba(6,182,212,0.05));
            border: 1px solid rgba(99,102,241,0.2);
            border-radius: 12px; padding: 16px; margin-top: 16px;
        }
        .bio-text {
            line-height: 1.7; font-size: 14px; margin: 0;
            color: #f4f4f5; font-style: italic; word-break: break-word;
        }

        /* action buttons */
        .action-row {
            display: flex; gap: 8px;
            justify-content: flex-end;
            margin-top: 16px; flex-wrap: wrap;
        }
        .btn-ghost {
            padding: 8px 14px; border-radius: 8px;
            font-size: 12px; font-weight: 600;
            background: #27272a; color: var(--text);
            border: 1px solid var(--border);
            text-decoration: none; cursor: pointer;
            transition: background 0.2s; font-family: inherit;
        }
        .btn-ghost:hover { background: #3f3f46; }
        .btn-pdf {
            padding: 8px 14px; border-radius: 8px;
            font-size: 12px; font-weight: 600;
            background: linear-gradient(135deg,#dc2626,#ef4444);
            color: #fff; border: none; cursor: pointer;
            transition: opacity 0.2s; font-family: inherit;
        }
        .btn-pdf:hover { opacity: 0.85; }

        /* metrics */
        .metrics-grid {
            display: grid; grid-template-columns: 1fr;
            gap: 20px; margin-top: 20px;
        }
        @media (min-width: 768px) {
            .metrics-grid { grid-template-columns: 1fr 1fr; }
        }
        .m-title {
            font-size: 11px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px;
            color: #fff; margin: 0 0 16px;
        }

        /* progress bars */
        .pg { margin-bottom: 14px; }
        .pg:last-child { margin-bottom: 0; }
        .pg-top { display: flex; justify-content: space-between; margin-bottom: 6px; }
        .pg-name { font-size: 12px; font-weight: 600; color: var(--muted); }
        .pg-pct  { font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 5px; }
        .pg-bar  { height: 6px; background: #27272a; border-radius: 99px; overflow: hidden; }
        .pg-fill { height: 100%; border-radius: 99px; }
        .t-ind { color:var(--indigo);  background:rgba(99,102,241,0.12); }
        .f-ind { background:linear-gradient(90deg,#4f46e5,var(--indigo)); }
        .t-em  { color:var(--emerald); background:rgba(16,185,129,0.12); }
        .f-em  { background:linear-gradient(90deg,#059669,var(--emerald)); }
        .t-amb { color:var(--amber);   background:rgba(245,158,11,0.12); }
        .f-amb { background:linear-gradient(90deg,#d97706,var(--amber)); }
        .t-ros { color:var(--rose);    background:rgba(244,63,94,0.12); }
        .f-ros { background:linear-gradient(90deg,#e11d48,var(--rose)); }
        .t-cy  { color:var(--cyan);    background:rgba(6,182,212,0.12); }
        .f-cy  { background:linear-gradient(90deg,#0891b2,var(--cyan)); }
    </style>

    <!-- ═══════════════════════════════
         PRINT / PDF STYLES
    ════════════════════════════════ -->
    <style>
        @media print {
            body {
                background: #fff !important;
                color: #000 !important;
                padding: 0 !important;
                margin: 0 !important;
            }

            #screenView     { display: none !important; }
            .success-banner { display: none !important; }
            #resumePage     { display: block !important; }

            /* ── PAGE ── */
            .resume-page {
                display: block !important;
                width: 210mm;
                min-height: 297mm;
                margin: 0 auto;
                padding: 12mm 16mm;
                font-family: 'Segoe UI', Arial, sans-serif;
                color: #1a1a1a;
                font-size: 11px;
                background: #fff;
            }

            /* ── HEADER ── */
            .r-header {
                display: flex !important;
                align-items: flex-start;
                gap: 18px;
                margin-bottom: 14px;
                padding-bottom: 12px;
                border-bottom: 2px solid #1a1a1a;
            }
            .r-photo {
                width: 85px; height: 85px;
                border-radius: 50%;
                object-fit: cover;
                flex-shrink: 0;
                border: 2px solid #e2e8f0;
            }
            .r-initials {
                width: 85px; height: 85px;
                border-radius: 50%;
                background: #2563eb;
                display: flex !important;
                align-items: center;
                justify-content: center;
                font-size: 26px;
                font-weight: 800;
                color: #fff;
                flex-shrink: 0;
            }
            .r-header-info { padding-top: 2px; }
            .r-header-info h1 {
                font-size: 17px;
                font-weight: 700;
                color: #1a1a1a;
                margin: 0 0 5px;
                letter-spacing: -0.3px;
            }
            .r-header-info p {
                margin: 2px 0;
                font-size: 10.5px;
                color: #334155;
                display: flex;
                gap: 5px;
            }
            .r-header-info p strong {
                color: #1a1a1a;
                min-width: 75px;
                font-weight: 700;
            }

            /* ── SECTION ── */
            .r-section { margin-bottom: 12px; }
            .r-section-title {
                font-size: 10.5px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1.5px;
                color: #1a1a1a;
                border-bottom: 1.5px solid #1a1a1a;
                padding-bottom: 3px;
                margin: 0 0 7px;
            }

            /* ── SUMMARY ── */
            .r-summary-text {
                font-size: 10.5px;
                line-height: 1.65;
                color: #334155;
                margin: 0;
                text-align: justify;
            }

            /* ── INFO GRID ── */
            .r-info-grid {
                display: grid !important;
                grid-template-columns: 1fr 1fr;
                gap: 3px 20px;
            }
            .r-info-row {
                display: flex !important;
                gap: 5px;
                font-size: 10.5px;
                padding: 3px 0;
                color: #334155;
                border-bottom: 0.5px solid #f1f5f9;
            }
            .r-info-row strong {
                color: #1a1a1a;
                min-width: 78px;
                flex-shrink: 0;
                font-weight: 600;
            }

            /* ── SKILL BARS ── */
            .r-skill-row {
                display: flex !important;
                align-items: center;
                gap: 10px;
                margin-bottom: 6px;
                font-size: 10.5px;
            }
            .r-skill-name {
                min-width: 150px;
                color: #334155;
                flex-shrink: 0;
            }
            .r-skill-bar-bg {
                flex: 1;
                height: 7px;
                background: #e2e8f0;
                border-radius: 99px;
                overflow: hidden;
            }
            .r-skill-bar-fill {
                height: 100%;
                background: #1a1a1a;
                border-radius: 99px;
            }
            .r-skill-pct {
                min-width: 32px;
                text-align: right;
                font-weight: 700;
                color: #1a1a1a;
                font-size: 10.5px;
            }

            /* ── SOCIAL ── */
            .r-social-grid {
                display: grid !important;
                grid-template-columns: 1fr 1fr;
                gap: 3px 20px;
            }
            .r-social-row {
                display: flex !important;
                gap: 5px;
                font-size: 10.5px;
                color: #334155;
                padding: 3px 0;
                border-bottom: 0.5px solid #f1f5f9;
            }
            .r-social-row strong {
                color: #1a1a1a;
                min-width: 70px;
                flex-shrink: 0;
                font-weight: 600;
            }

            /* ── FOOTER ── */
            .r-footer {
                margin-top: 16px;
                padding-top: 8px;
                border-top: 1px solid #e2e8f0;
                font-size: 9px;
                color: #94a3b8;
                text-align: center;
            }
        }
    </style>
</head>
<body>

<!-- SUCCESS BANNER -->
<div class="success-banner">
    &#10003;&nbsp; Profile saved successfully! Welcome,
    <strong><%= nameAttr %></strong>.
</div>

<!-- ══════════════════════════════
     SCREEN VIEW
══════════════════════════════ -->
<div class="dashboard" id="screenView">

    <!-- LEFT COLUMN -->
    <div style="display:flex;flex-direction:column;gap:18px;">

        <!-- Avatar / Photo card -->
        <div class="card hero">
            <div class="av-wrap">
                <% if (hasPhoto) { %>
                    <img class="av-photo"
                         src="uploads/<%= photoPath %>"
                         alt="<%= nameAttr %>"/>
                <% } else { %>
                    <div class="av"><%= initials %></div>
                <% } %>
            </div>
            <h3><%= nameAttr %></h3>
            <div class="prog-badge"><%= programAttr %></div>
            <a href="mailto:<%= emailAttr %>" class="btn-msg">
                &#9993;&nbsp; Send Message
            </a>
        </div>

        <!-- Socials card -->
        <div class="card" style="padding:16px;">
            <ul class="s-list">
                <li class="s-item">
                    <div class="s-label">
                        <img src="https://img.icons8.com/color/24/domain.png" alt="web"/>
                        Website
                    </div>
                    <div class="s-val"><%= websiteAttr %></div>
                </li>
                <li class="s-item">
                    <div class="s-label">
                        <img src="https://img.icons8.com/material-outlined/24/ffffff/github.png" alt="gh"/>
                        GitHub
                    </div>
                    <div class="s-val"><%= githubAttr %></div>
                </li>
                <li class="s-item">
                    <div class="s-label">
                        <img src="https://img.icons8.com/ios-filled/24/ffffff/twitterx--v2.png" alt="tw"/>
                        Twitter
                    </div>
                    <div class="s-val"><%= twitterAttr %></div>
                </li>
                <li class="s-item">
                    <div class="s-label">
                        <img src="https://img.icons8.com/color/24/instagram-new--v1.png" alt="ig"/>
                        Instagram
                    </div>
                    <div class="s-val"><%= instagramAttr %></div>
                </li>
                <li class="s-item">
                    <div class="s-label">
                        <img src="https://img.icons8.com/color/24/facebook-new.png" alt="fb"/>
                        Facebook
                    </div>
                    <div class="s-val"><%= facebookAttr %></div>
                </li>
            </ul>
        </div>

    </div><!-- end left -->

    <!-- RIGHT COLUMN -->
    <div>

        <!-- Info + Bio card -->
        <div class="card">
            <div class="pill-grid">
                <div class="pill">
                    <div class="pill-lbl">Full Name</div>
                    <div class="pill-val"><%= nameAttr %></div>
                </div>
                <div class="pill">
                    <div class="pill-lbl">Email</div>
                    <div class="pill-val"
                         style="color:var(--indigo);font-size:11px;">
                        <%= emailAttr %>
                    </div>
                </div>
                <div class="pill">
                    <div class="pill-lbl">Student ID</div>
                    <div class="pill-val"><%= idAttr %></div>
                </div>
                <div class="pill">
                    <div class="pill-lbl">Program</div>
                    <div class="pill-val" style="font-size:11px;">
                        <%= programAttr %>
                    </div>
                </div>
            </div>

            <!-- Bio -->
            <div class="bio-box">
                <div class="pill-lbl" style="margin-bottom:6px;">
                    Professional Bio
                </div>
                <% if (hasBio) { %>
                    <p class="bio-text">"<%= bioAttr.trim() %>"</p>
                <% } else { %>
                    <span style="color:var(--muted);
                                 font-style:italic;
                                 font-size:12px;">
                        No biography provided.
                    </span>
                <% } %>
            </div>

            <!-- Action Buttons -->
            <div class="action-row">
                <a href="index.html" class="btn-ghost">
                    &#9998; Modify Profile
                </a>
                <a href="ProfileController?action=list" class="btn-ghost">
                    &#128196; View All
                </a>
                <button class="btn-pdf" onclick="exportPDF()">
                    &#128438; Export PDF Resume
                </button>
            </div>
        </div>

        <!-- Metrics grid -->
        <div class="metrics-grid">

            <!-- Skills card -->
            <div class="card">
                <p class="m-title">&#128200; Skill Metrics</p>
                <div class="pg">
                    <div class="pg-top">
                        <span class="pg-name">Web Design</span>
                        <span class="pg-pct t-ind"><%= webDesignVal %>%</span>
                    </div>
                    <div class="pg-bar">
                        <div class="pg-fill f-ind"
                             style="width:<%= webDesignVal %>%"></div>
                    </div>
                </div>
                <div class="pg">
                    <div class="pg-top">
                        <span class="pg-name">Website Markup</span>
                        <span class="pg-pct t-em"><%= webMarkupVal %>%</span>
                    </div>
                    <div class="pg-bar">
                        <div class="pg-fill f-em"
                             style="width:<%= webMarkupVal %>%"></div>
                    </div>
                </div>
                <div class="pg">
                    <div class="pg-top">
                        <span class="pg-name">One Page Design</span>
                        <span class="pg-pct t-amb"><%= onePageVal %>%</span>
                    </div>
                    <div class="pg-bar">
                        <div class="pg-fill f-amb"
                             style="width:<%= onePageVal %>%"></div>
                    </div>
                </div>
                <div class="pg">
                    <div class="pg-top">
                        <span class="pg-name">Mobile Responsive</span>
                        <span class="pg-pct t-ros"><%= mobileTemplateVal %>%</span>
                    </div>
                    <div class="pg-bar">
                        <div class="pg-fill f-ros"
                             style="width:<%= mobileTemplateVal %>%"></div>
                    </div>
                </div>
                <div class="pg">
                    <div class="pg-top">
                        <span class="pg-name">Backend / API</span>
                        <span class="pg-pct t-cy"><%= backendApiVal %>%</span>
                    </div>
                    <div class="pg-bar">
                        <div class="pg-fill f-cy"
                             style="width:<%= backendApiVal %>%"></div>
                    </div>
                </div>
            </div>

            <!-- Summary card -->
            <div class="card">
                <p class="m-title">&#128203; Student Summary</p>
                <ul class="s-list" style="gap:7px;">
                    <li class="s-item">
                        <span class="s-label">Student ID</span>
                        <span class="s-val"><%= idAttr %></span>
                    </li>
                    <li class="s-item">
                        <span class="s-label">Program</span>
                        <span class="s-val" style="font-size:11px;">
                            <%= programAttr %>
                        </span>
                    </li>
                    <li class="s-item">
                        <span class="s-label">Email</span>
                        <span class="s-val"
                              style="color:var(--cyan);font-size:11px;">
                            <%= emailAttr %>
                        </span>
                    </li>
                    <li class="s-item">
                        <span class="s-label">Hobbies</span>
                        <span class="s-val" style="font-size:11px;">
                            <%= hobbiesAttr %>
                        </span>
                    </li>
                </ul>
            </div>

        </div><!-- end metrics-grid -->
    </div><!-- end right -->

</div><!-- end dashboard -->


<!-- ══════════════════════════════
     RESUME PAGE — print only
══════════════════════════════ -->
<div id="resumePage" style="display:none;">
<div class="resume-page">

    <!-- ── HEADER — photo + basic info only ── -->
    <div class="r-header">
        <% if (hasPhoto) { %>
            <img class="r-photo"
                 src="uploads/<%= photoPath %>"
                 alt="<%= nameAttr %>"/>
        <% } else { %>
            <div class="r-initials"><%= initials %></div>
        <% } %>
        <div class="r-header-info">
            <h1><%= nameAttr %></h1>
            <p><strong>Program &nbsp;&nbsp;&nbsp;:</strong> <%= programAttr %></p>
            <p><strong>Student ID :</strong> <%= idAttr %></p>
            <p><strong>Email &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</strong> <%= emailAttr %></p>
        </div>
    </div>

    <!-- ── SUMMARY ── -->
    <% if (hasBio) { %>
    <div class="r-section">
        <div class="r-section-title">Summary</div>
        <p class="r-summary-text"><%= bioAttr.trim() %></p>
    </div>
    <% } %>

    <!-- ── PERSONAL INFORMATION ── -->
    <div class="r-section">
        <div class="r-section-title">Personal Information</div>
        <div class="r-info-grid">
            <div class="r-info-row">
                <strong>Full Name</strong>
                <%= nameAttr %>
            </div>
            <div class="r-info-row">
                <strong>Student ID</strong>
                <%= idAttr %>
            </div>
            <div class="r-info-row">
                <strong>Program</strong>
                <%= programAttr %>
            </div>
            <div class="r-info-row">
                <strong>Email</strong>
                <%= emailAttr %>
            </div>
            <div class="r-info-row">
                <strong>Hobbies</strong>
                <%= hobbiesAttr %>
            </div>
        </div>
    </div>

    <!-- ── TECHNICAL SKILLS ── -->
    <div class="r-section">
        <div class="r-section-title">Technical Skills</div>
        <div class="r-skill-row">
            <span class="r-skill-name">Web Design</span>
            <div class="r-skill-bar-bg">
                <div class="r-skill-bar-fill"
                     style="width:<%= webDesignVal %>%"></div>
            </div>
            <span class="r-skill-pct"><%= webDesignVal %>%</span>
        </div>
        <div class="r-skill-row">
            <span class="r-skill-name">Website Markup</span>
            <div class="r-skill-bar-bg">
                <div class="r-skill-bar-fill"
                     style="width:<%= webMarkupVal %>%"></div>
            </div>
            <span class="r-skill-pct"><%= webMarkupVal %>%</span>
        </div>
        <div class="r-skill-row">
            <span class="r-skill-name">One Page Design</span>
            <div class="r-skill-bar-bg">
                <div class="r-skill-bar-fill"
                     style="width:<%= onePageVal %>%"></div>
            </div>
            <span class="r-skill-pct"><%= onePageVal %>%</span>
        </div>
        <div class="r-skill-row">
            <span class="r-skill-name">Mobile Responsive</span>
            <div class="r-skill-bar-bg">
                <div class="r-skill-bar-fill"
                     style="width:<%= mobileTemplateVal %>%"></div>
            </div>
            <span class="r-skill-pct"><%= mobileTemplateVal %>%</span>
        </div>
        <div class="r-skill-row">
            <span class="r-skill-name">Backend / API</span>
            <div class="r-skill-bar-bg">
                <div class="r-skill-bar-fill"
                     style="width:<%= backendApiVal %>%"></div>
            </div>
            <span class="r-skill-pct"><%= backendApiVal %>%</span>
        </div>
    </div>

    <!-- ── SOCIAL & NETWORKS — sekali je kat sini ── -->
    <div class="r-section">
        <div class="r-section-title">Social &amp; Networks</div>
        <div class="r-social-grid">
            <div class="r-social-row">
                <strong>Website</strong>
                <%= websiteAttr %>
            </div>
            <div class="r-social-row">
                <strong>GitHub</strong>
                <%= githubAttr %>
            </div>
            <div class="r-social-row">
                <strong>Twitter / X</strong>
                <%= twitterAttr %>
            </div>
            <div class="r-social-row">
                <strong>Instagram</strong>
                <%= instagramAttr %>
            </div>
            <div class="r-social-row">
                <strong>Facebook</strong>
                <%= facebookAttr %>
            </div>
        </div>
    </div>

    <!-- ── FOOTER ── -->
    <div class="r-footer">
        Generated by Profile Management System &mdash;
        <%= nameAttr %> &mdash; <%= emailAttr %>
    </div>

</div>
</div><!-- end resumePage -->


<script>
function exportPDF() {
    document.getElementById("screenView").style.display  = "none";
    document.getElementById("resumePage").style.display  = "block";
    window.print();
    setTimeout(function() {
        document.getElementById("screenView").style.display = "";
        document.getElementById("resumePage").style.display = "none";
    }, 1500);
}
</script>

</body>
</html>