<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<html>
<head>
    <title>로그인 처리</title>
</head>
<body>
<%
    // 로그인 폼에서 전달된 값
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String nickname = "";

    // 데이터베이스 연결 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 기본 로그인 성공/실패 플래그
    boolean loginSuccess = false;
    String errorMessage = "";

    // MySQL 데이터베이스 접속 정보
    String dbUser = "root"; // MySQL 사용자 계정
    String dbPassword = "Movie1234!"; // MySQL 비밀번호
    String jdbcUrl = "jdbc:mysql://localhost:3306/movie_project?serverTimezone=UTC"; // 데이터베이스 URL

    try {
        // JDBC 드라이버 로드
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 데이터베이스 연결
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // 사용자 인증 쿼리
        String loginQuery = "SELECT pw, nickname FROM users WHERE id = ?";
        pstmt = conn.prepareStatement(loginQuery);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 데이터베이스에 저장된 암호화된 비밀번호 가져오기
            String hashedPassword = rs.getString("pw");

            // 입력한 비밀번호를 동일한 방식으로 암호화
            String inputHashedPassword = org.apache.commons.codec.digest.DigestUtils.sha256Hex(password);

            // 비밀번호 비교
            if (hashedPassword.equals(inputHashedPassword)) {
                loginSuccess = true;
                nickname = rs.getString("nickname");
            } else {
                errorMessage = "password_incorrect"; // 비밀번호 틀림
            }
        } else {
            errorMessage = "user_not_found"; // 사용자 없음
        }

    } catch (Exception e) {
        errorMessage = "오류 발생: " + e.getMessage();
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!-- 로그인 결과 알림 -->
<% if (loginSuccess) { 
    // 로그인 성공: 홈 페이지로 이동
    session.setAttribute("userId", username);
    session.setAttribute("nickname", nickname);
    response.sendRedirect("/index.jsp?login=success");
} else {
    // 로그인 실패: 에러 메시지를 포함하여 로그인 페이지로 리다이렉트
    response.sendRedirect("login.jsp?error=" + errorMessage);
} %>
</body>
</html>
