<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    
    if (userId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            String dbUser = "root";
            String dbPassword = "Movie1234!";
            
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            
            // favorite 테이블에서 사용자 데이터 삭제 (외래 키 제약 조건 때문에 먼저 삭제)
            String deleteFavorites = "DELETE FROM favorite WHERE user_id = ?";
            pstmt = conn.prepareStatement(deleteFavorites);
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // users 테이블에서 사용자 삭제
            String deleteUser = "DELETE FROM users WHERE id = ?";
            pstmt = conn.prepareStatement(deleteUser);
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            
            // 세션 무효화
            session.invalidate();
            
            out.print("success");
            
        } catch(Exception e) {
            e.printStackTrace();
            out.print("error");
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    } else {
        out.print("error");
    }
%> 