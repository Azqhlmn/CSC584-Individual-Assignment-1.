<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Directory</title>
    <style>
        :root {
            --bg:     #09090b;
            --card:   #18181b;
            --border: rgba(255,255,255,0.08);
            --text:   #f4f4f5;
            --muted:  #a1a1aa;
            --indigo: #6366f1;
            --cyan:   #06b6d4;
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: var(--bg);
            color: var(--text);
            margin: 0; padding: 40px 20px;
        }
        .wrapper { max-width: 1100px; margin: auto; }
        .top-bar {
            display: flex; align-items: center;
            justify-content: space-between;
            flex-wrap: wrap; gap: 12px; margin-bottom: 6px;
        }
        h2 { font-size: 23px; margin: 0; }
        .badge {
            background: rgba(99,102,241,0.15);
            color: var(--indigo);
            padding: 3px 12px; border-radius: 100px;
            font-size: 12px; font-weight: 700;
        }
        .sub { color:var(--muted); font-size:13px; margin:0 0 18px; }

        /* search */
        #searchBox {
            width: 100%; padding: 13px 16px; margin-bottom: 16px;
            border-radius: 10px; border: 1px solid var(--border);
            background: var(--card); color: var(--text);
            font-size: 14px; font-family: inherit;
            outline: none; transition: border-color 0.2s;
        }
        #searchBox:focus { border-color: var(--indigo); }

        /* table */
        table {
            width: 100%; border-collapse: collapse;
            background: var(--card); border-radius: 14px;
            overflow: hidden; border: 1px solid var(--border);
        }
        th {
            padding: 12px 16px; text-align: left;
            background: rgba(99,102,241,0.08); color: var(--indigo);
            font-size: 10px; text-transform: uppercase;
            letter-spacing: 1px; font-weight: 700;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 13px 16px; font-size: 13px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        tr:last-child td { border-bottom: none; }
        tbody tr:hover td { background: rgba(255,255,255,0.025); }

        /* avatar / photo */
        .mini-av {
            width: 36px; height: 36px; border-radius: 50%;
            background: linear-gradient(135deg,#4f46e5,#06b6d4);
            display: inline-flex; align-items: center;
            justify-content: center;
            font-weight: 800; font-size: 13px; color: #fff;
            flex-shrink: 0; overflow: hidden;
        }
        .mini-av img {
            width: 100%; height: 100%;
            object-fit: cover; border-radius: 50%;
        }
        .name-cell { display: flex; align-items: center; gap: 10px; }

        /* view button */
        .view-btn {
            color: var(--indigo); text-decoration: none;
            font-weight: 600; font-size: 12px;
            padding: 5px 12px;
            border: 1px solid rgba(99,102,241,0.3);
            border-radius: 6px; transition: background 0.2s;
            white-space: nowrap; display: inline-block;
        }
        .view-btn:hover { background: rgba(99,102,241,0.1); }

        /* empty */
        .empty {
            text-align: center; padding: 60px 20px;
            background: var(--card); border-radius: 14px;
            border: 1px solid var(--border); color: var(--muted);
        }
        .empty a { color:var(--indigo); text-decoration:none; font-weight:600; }

        #noResult {
            display: none; text-align: center; padding: 18px;
            color: var(--muted); font-size: 13px;
            background: var(--card); border-radius: 10px;
            margin-top: 10px; border: 1px solid var(--border);
        }
        .back {
            display: inline-block; margin-top: 22px;
            color: var(--muted); text-decoration: none; font-size: 13px;
        }
        .back:hover { color: var(--indigo); }
    </style>
</head>
<body>
<div class="wrapper">

    <div class="top-bar">
        <h2>&#128196; Profile Directory</h2>
        <span class="badge">${profileList.size()} total</span>
    </div>
    <p class="sub">
        Search by name or program — filters instantly, no page reload.
    </p>

    <c:choose>
        <c:when test="${empty profileList}">
            <div class="empty">
                <p style="font-size:42px;margin:0 0 10px">&#128100;</p>
                <p style="font-size:16px;font-weight:600;margin:0 0 6px">
                    No profiles yet
                </p>
                <p style="margin:0 0 18px;font-size:13px;">
                    Submit the form to create the first one.
                </p>
                <a href="index.html">&#43; Create Profile</a>
            </div>
        </c:when>

        <c:otherwise>
            <!-- Live Search input -->
            <input type="text" id="searchBox"
                   onkeyup="liveSearch()"
                   placeholder="Search by name or program...">

            <!-- Table with c:forEach -->
            <table id="profileTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Photo</th>
                        <th>Name</th>
                        <th>Student ID</th>
                        <th>Program</th>
                        <th>Email</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${profileList}"
                               varStatus="loop">
                        <tr>
                            <td style="color:var(--muted);">
                                ${loop.count}
                            </td>
                            <td>
                                <div class="mini-av">
                                    <c:choose>
                                        <c:when test="${not empty p.photoPath}">
                                            <img src="uploads/${p.photoPath}"
                                                 alt="${p.fullName}"/>
                                        </c:when>
                                        <c:otherwise>
                                            ${p.initials}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>${p.fullName}</td>
                            <td style="color:var(--muted);">
                                ${p.studentId}
                            </td>
                            <td>${p.program}</td>
                            <td style="color:var(--cyan);">
                                ${p.email}
                            </td>
                            <td>
                                <a class="view-btn"
                                   href="ProfileController?id=${p.id}">
                                    View &rarr;
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <p id="noResult">No matching profiles found.</p>
        </c:otherwise>
    </c:choose>

    <a class="back" href="index.html">&larr; Back to Create Profile</a>
</div>

<script>
function liveSearch() {
    var q    = document.getElementById("searchBox").value.toLowerCase();
    var rows = document.querySelectorAll("#profileTable tbody tr");
    var vis  = 0;
    for (var i = 0; i < rows.length; i++) {
        // col 2 = name, col 4 = program (0-indexed)
        var name    = rows[i].children[2].textContent.toLowerCase();
        var program = rows[i].children[4].textContent.toLowerCase();
        var match   = name.indexOf(q) > -1 || program.indexOf(q) > -1;
        rows[i].style.display = match ? "" : "none";
        if (match) vis++;
    }
    document.getElementById("noResult").style.display =
        vis === 0 ? "block" : "none";
}
</script>
</body>
</html>