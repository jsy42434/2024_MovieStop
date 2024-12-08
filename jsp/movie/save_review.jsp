<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    String userId = new String(request.getParameter("user_id").getBytes("ISO-8859-1"), "UTF-8");
    String movieId = request.getParameter("movie_id");
    String reviewContent = new String(request.getParameter("review_content").getBytes("ISO-8859-1"), "UTF-8");
    String reviewStar = request.getParameter("review_star");

    Connection conn = null;
    PreparedStatement pstmt = null;
    String message = "리뷰가 등록되었습니다.";

    String dbUrl = "jdbc:mysql://localhost:3306/movie_project?serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = "Movie1234!";
    
    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");

        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        // SQL 쿼리 실행
        String sql = "INSERT INTO review (user_id, movie_id, review_content, review_star, created_at) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, movieId);
        pstmt.setString(3, reviewContent);
        pstmt.setInt(4, Integer.parseInt(reviewStar));
        pstmt.setTimestamp(5, new Timestamp(System.currentTimeMillis())); // 현재 시간 삽입
        pstmt.executeUpdate();

    } catch (SQLException e) {
        message = "리뷰 등록 중 데이터베이스 오류가 발생했습니다: " + e.getMessage();
        e.printStackTrace();
    } catch (Exception e) {
        message = "리뷰 등록 중 예외가 발생했습니다: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }

    // 결과 메시지 출력
    out.println("<script>alert('" + message +"');</script>");
    response.sendRedirect("/jsp/movie/movie_information.jsp?movie_id="+movieId);
%>
