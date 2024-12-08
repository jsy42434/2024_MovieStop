<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 프로필</title>
    <link rel="stylesheet" href="/style/profile/profile-style.css">
</head>
<body>
    <div id="navigation">
        <jsp:include page="/jsp/home/nav.jsp" />
    </div>
    <div id="profile-container">
        <img src="/photo/default-profile.jpg" alt="프로필 사진" id="profile-image">
        <div id="nickname">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                    String dbUser = "root";
                    String dbPassword = "Movie1234!";
                    
                    String userId = (String) session.getAttribute("userId");
                    
                    conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                    String sql = "SELECT nickname FROM users WHERE id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userId);
                    
                    rs = pstmt.executeQuery();
                    
                    if(rs.next()) {
                        out.print(rs.getString("nickname"));
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                }
            %>
        </div>
        <button id="delete-account">회원탈퇴</button>
    </div>
    <div id="profile-nav">
        <button class="profile-nav-button" onclick="location.href='/jsp/profile/profile.jsp'">찜 목록</button>
        <button class="profile-nav-button" onclick="location.href='/jsp/profile/profile_change.jsp'">사용자 정보 변경</button>
    </div>
    <hr id="divider">
    
    <div class="favorite-list">
        <h2>찜 목록</h2>
        <table>
            <thead>
                <tr>
                    <th>포스터</th>
                    <th>영화 제목</th>
                    <th>장르</th>
                    <th>평점</th>
                </tr>
            </thead>
            <tbody>
                <%
                    conn = null;
                    pstmt = null;
                    rs = null;
                    
                    try {
                        // DB 연결
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                        String dbUser = "root";
                        String dbPassword = "Movie1234!";
                        
                        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                        
                        // favorite 테이블에서 데이터 가져오기
                        String sql = "SELECT movie_id FROM favorite WHERE user_id = ? ORDER BY fav_time DESC";
                        pstmt = conn.prepareStatement(sql);
                        String userId = (String) session.getAttribute("userId");
                        pstmt.setString(1, userId);
                        
                        rs = pstmt.executeQuery();
                        
                        // TMDB API 설정
                        String bearerToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g";
                        
                        while(rs.next()) {
                            int movieId = rs.getInt("movie_id");
                            
                            // TMDB API 호출
                            String apiUrl = "https://api.themoviedb.org/3/movie/" + movieId + "?language=ko-KR";
                            URL url = new URL(apiUrl);
                            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                            connection.setRequestMethod("GET");
                            connection.setRequestProperty("Authorization", bearerToken);
                            
                            BufferedReader reader = new BufferedReader(
                                new InputStreamReader(connection.getInputStream(), "UTF-8"));
                            StringBuilder responseBuilder = new StringBuilder();
                            String line;
                            
                            while ((line = reader.readLine()) != null) {
                                responseBuilder.append(line);
                            }
                            reader.close();
                            
                            JSONObject movieData = new JSONObject(responseBuilder.toString());
                            String posterPath = movieData.getString("poster_path");
                            String fullPosterPath = "https://image.tmdb.org/t/p/w200" + posterPath;
                %>
                            <tr onclick="location.href='/jsp/movie/movie_information.jsp?movie_id=<%= movieId %>'">
                                <td class="poster-cell"><img src="<%= fullPosterPath %>" alt="영화 포스터"></td>
                                <td class="info-cell">
                                    <div class="movie-title"><%= movieData.getString("title") %></div>
                                    <div class="movie-genre"><%= movieData.getJSONArray("genres").getJSONObject(0).getString("name") %></div>
                                </td>
                                <td class="rating-cell">
                                    <div class="movie-rating">★ <%= String.format("%.1f", movieData.getDouble("vote_average")) %></div>
                                </td>
                            </tr>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        if(rs != null) try { rs.close(); } catch(Exception e) {}
                        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                        if(conn != null) try { conn.close(); } catch(Exception e) {}
                    }
                %>
            </tbody>
        </table>
    </div>
    <script>
    document.getElementById('delete-account').addEventListener('click', function() {
        if (confirm('회원을 탈퇴하시겠습니까?')) {
            // AJAX를 사용하여 서버에 삭제 요청
            fetch('/jsp/profile/delete_account.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'userId=<%= session.getAttribute("userId") %>'
            })
            .then(response => response.text())
            .then(data => {
                if (data.trim() === 'success') {
                    alert('회원 탈퇴 되었습니다.');
                    window.location.href = '/index.jsp';
                } else {
                    alert('회원 탈퇴 처리 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('회원 탈퇴 처리 중 오류가 발생했습니다.');
            });
        }
    });
    </script>
</body>
</html>