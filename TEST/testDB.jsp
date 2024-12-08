<%@ page import="java.sql.*" %>
<%
    // Database connection details
    String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root"; // MySQL 사용자 이름
    String dbPassword = "Movie1234!"; // MySQL 비밀번호
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Load the MySQL driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // 1. Insert test
        String insertQuery = "INSERT INTO users (id, pw, nickname) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(insertQuery);
        pstmt.setString(1, "test_user");
        pstmt.setString(2, "password123");
        pstmt.setString(3, "TestNickname");
        int rowsInserted = pstmt.executeUpdate();
        out.println(rowsInserted + " row(s) inserted into users table.<br>");
        pstmt.close();

        
        // 2. Update test
        String updateQuery = "UPDATE users SET nickname = ? WHERE id = ?";
        pstmt = conn.prepareStatement(updateQuery);
        pstmt.setString(1, "UpdatedNickname");
        pstmt.setString(2, "test_user");
        int rowsUpdated = pstmt.executeUpdate();
        out.println(rowsUpdated + " row(s) updated in users table.<br>");
        pstmt.close();

        // 3. Delete test
        String deleteQuery = "DELETE FROM users WHERE id = ?";
        pstmt = conn.prepareStatement(deleteQuery);
        pstmt.setString(1, "test_user");
        int rowsDeleted = pstmt.executeUpdate();
        out.println(rowsDeleted + " row(s) deleted from users table.<br>");
        pstmt.close();

        // 4. Select test
        String selectQuery = "SELECT * FROM users";
        pstmt = conn.prepareStatement(selectQuery);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            out.println("User ID: " + rs.getString("id") + ", Nickname: " + rs.getString("nickname") + "<br>");
        }

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
