<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<html>
<head>
    <title>회원가입 처리</title>
</head>
<body>
<%
    // 회원가입 폼에서 전달된 값
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm_password");
    String nickname = new String(request.getParameter("nickname").getBytes("ISO-8859-1"), "UTF-8");
    // 데이터베이스 연결 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 기본 성공/실패 플래그
    boolean signupSuccess = false;
    String message = "";
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
        
        // 아이디 중복 확인을 위한 코드
        String checkQuery = "SELECT COUNT(*) FROM users WHERE id = ?";
        pstmt = conn.prepareStatement(checkQuery);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        // 1. 비밀번호와 확인 비밀번호가 일치하는지 확인
        if (!password.equals(confirmPassword)) {
            errorMessage = "password_mismatch";
        }

        // 2. 아이디 조건 체크 (4~16자)
        else if (username.length() < 4 || username.length() > 16) {
            errorMessage = "id_length";
        }

        // 3. 비밀번호 조건 체크 (8~16자의 영문, 특수문자 조합)
        else if (password.length() < 8 || password.length() > 16 || !password.matches(".*[a-zA-Z].*") || !password.matches(".*[!@#$%^&*].*")) {
            errorMessage = "weak_password";
        }

        // 4. 아이디 중복 확인
        else if (rs.next() && rs.getInt(1) > 0) {
            errorMessage = "id_exists";
        }

        // 5. 모든 조건을 만족할 경우 회원가입 진행
        else if (errorMessage.isEmpty()) {
            // 비밀번호를 암호화(SHA-256)
            String hashedPassword = org.apache.commons.codec.digest.DigestUtils.sha256Hex(password);

            // 사용자 정보 삽입
            String insertQuery = "INSERT INTO users (id, pw, nickname) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertQuery);
            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, nickname);
            
            int result = pstmt.executeUpdate();

            if (result > 0) {
                signupSuccess = true;
                message = "success";
            } else {
                errorMessage = "database";
            }
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

<!-- 회원가입 결과 알림 -->
<% if (signupSuccess) { 
    response.sendRedirect("../login/login.jsp?signup="+message);
 } else {
    response.sendRedirect("signup.jsp?error="+errorMessage);
 } %>
</body>
</html>
