<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovieStop</title>
    <link rel="stylesheet" href="/style/home/nav-style.css"> 
    <%
    String userId = (String) session.getAttribute("userId"); // 세션에서 사용자 ID 가져오기
    %>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-container">
            <div class="navbar-left">
                <div class="hamburger" id="hamburger">&#9776;</div>
                <a href="/index.jsp" class="logo">
                    <img src="/photo/logo01.png" alt="이미지 없음">
                </a>
            </div>
            <div class="menu" id="menu">
                <ul>
                    <li class="genre-item">
                        <a href="javascript:void(0)" class="genre-link" id="genreToggle">장르</a>
                        <ul class="genre-submenu">
                            <li><a href="/jsp/genre/action.jsp">액션</a></li>
                            <li><a href="/jsp/genre/animation.jsp">애니메이션</a></li>
                            <li><a href="/jsp/genre/comedy.jsp">코미디</a></li>
                            <li><a href="/jsp/genre/horror.jsp">호러</a></li>
                        </ul>
                    </li>
                    <li><a href="/jsp/home/category.jsp">카테고리</a></li>
                    <li><a href="/jsp/search/search.jsp"> 검색 </a></li>
                    <li><div class="menu-text">
                        <p>MovieStop © 2024. All rights reserved.</p><br>
                        <p>©동의대학교 컴퓨터소프트웨어공학과 진열정</p>
                        <p>진열정=배미'진'+장성'열'+강민'정'</p>
                    </div>
                    </li>
                </ul>
            </div>
            <div class="nav-buttons">
                <% if (userId != null) { %>
                    <!-- 로그인 상태 -->
                    <span class="user-id"><%= userId %></span>
                    <a href="/jsp/profile/profile.jsp" class="mypage-btn">마이페이지</a>
                    <a href="/jsp/login/logout.jsp" class="logout-btn">로그아웃</a>
                <% } else { %>
                    <!-- 비로그인 상태 -->
                    <a href="/jsp/login/login.jsp" class="login-btn">로그인</a>
                    <a href="/jsp/signup/signup.jsp" class="signup-btn">회원가입</a>
                <% } %>
            </div>
        </div>
    </nav>
    <script src ="/JS/hamburger.js"></script>
</body>
</html>