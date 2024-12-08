<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // 요청으로부터 user_id와 movie_id 가져오기
    String user_id = request.getParameter("user_id");
    String movie_id = request.getParameter("movie_id");

    // 데이터베이스 연결 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 에러 메시지 플래그
    boolean isDuplicate = false;
    
    // JDBC 드라이버 로드 및 데이터베이스 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    String jdbcUrl = "jdbc:mysql://localhost:3306/movie_project?serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = "Movie1234!"; // 비밀번호 설정
    
    if(user_id==null){
        %>
            <script>
                alert("로그인 후 이용할 수 있습니다.");
                history.back();
            </script>
        <%
    }
    try {
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // 중복 확인 쿼리
        String query = "SELECT COUNT(*) FROM favorite WHERE user_id = ? AND movie_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, user_id);
        pstmt.setString(2, movie_id);

        rs = pstmt.executeQuery();

        // 중복이 존재하는 경우 플래그 설정
        if (rs.next() && rs.getInt(1) > 0) {
            isDuplicate = true;
        }

    } catch (Exception e) {
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

    if (isDuplicate) {
%>
        <script>
            alert("이미 찜된 항목입니다.");
            history.back(); // 이전 페이지로 이동
        </script>
<%
    } else {
        // 중복이 아니라면 찜 목록에 추가
        try {
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            String insertQuery = "INSERT INTO favorite (user_id, movie_id) VALUES (?, ?)";
            pstmt = conn.prepareStatement(insertQuery);
            pstmt.setString(1, user_id);
            pstmt.setString(2, movie_id);

            int rowsInserted = pstmt.executeUpdate();
            if (rowsInserted > 0) {
%>
                <script>
                    alert("찜 목록에 추가되었습니다!");
                    history.back();
                </script>
<%
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
