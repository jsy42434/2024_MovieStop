<%@ page import="java.sql.*" %>
<%
    // Database connection details
    String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root"; // MySQL 사용자 이름
    String dbPassword = "Movie1234!"; // MySQL 비밀번호
    Connection conn = null;

    try {
        // Load the MySQL driver
        Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 드라이버 로드
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword); // 연결 시도
        out.println("Database connection successful!");
    } catch (Exception e) {
        out.println("Database connection failed: " + e.getMessage()); // 오류 출력
    } finally {
        if (conn != null) conn.close(); // 연결 닫기
    }
%>