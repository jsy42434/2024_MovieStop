<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page language="java" %>
<%@ page import="java.io.BufferedReader, java.io.InputStreamReader, java.net.HttpURLConnection, java.net.URL" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<%! 
    void fetchMovies(String apiUrl, String bearerToken, JspWriter out) throws Exception {
        URL url = new URL(apiUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Accept", "application/json");
        connection.setRequestProperty("Authorization","Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g"); // Bearer Token 사용

        int responseCode = connection.getResponseCode();
        if (responseCode == 200) {
            BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
            StringBuilder responseBuilder = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                responseBuilder.append(line);
            }
            reader.close();

            JSONObject jsonResponse = new JSONObject(responseBuilder.toString());
            JSONArray results = jsonResponse.getJSONArray("results");

            for (int i = 0; i < Math.min(15, results.length()); i++) {
                try {
                    JSONObject movie = results.getJSONObject(i);
                    String title = movie.optString("title", "제목 없음");
                    String posterPath = movie.optString("poster_path", null);
                    
                    // 포스터가 없는 영화는 건너뛰기
                    if (posterPath == null || posterPath.equals("null") || posterPath.isEmpty()) {
                        continue;
                    }
                    
                    int movieId = movie.getInt("id");
                    String fullPosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;
                    
                    out.println("<div class='movie-item' onclick='location.href=\"/jsp/movie/movie_information.jsp?movie_id=" + movieId + "\"'>");
                    out.println("<img src='" + fullPosterPath + "' alt='" + title + "' class='movie-poster'>");
                    out.println("<p class='movie-title'>" + title + "</p>");
                    out.println("</div>");
                    
                } catch (Exception e) {
                    out.println("<p>영화 데이터를 처리하는 중 오류 발생: " + e.getMessage() + "</p>");
                }
            }
        } else {
            out.println("<p>API 요청 실패: 응답 코드 " + responseCode + "</p>");
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovieStop</title>
    <link rel="stylesheet" href="/style/home/index-style.css">
</head>
<body>
    <jsp:include page="/jsp/home/nav.jsp"/> 
    <header>
        <div class="slide-container">
            <button class="slide-btn right-btn" onclick="moveSlide('right')">←</button>
            <div class="slide">
                <% 
                    String[] imagePaths = {"/photo/movie1.png", "/photo/movie2.png", "/photo/movie3.png"};
                    for (String path : imagePaths) {
                %>
                    <img src="<%= path %>" alt="슬라이드 이미지">
                <% } %>
            </div>
            
            <button class="slide-btn left-btn" onclick="moveSlide('left')">→</button>
        </div>
        <br>
        <div class="dots-container">
            <% for (int i = 0; i < imagePaths.length; i++) { %>
                <span class="dot" data-slide="<%= i %>"></span>
            <% } %>
        </div>
        <br>
    </header>

    <div class="category-container">
        <h2 class="main-title">요즘엠지,,가장 인기 있는 영화⭐⭐⭐⭐</h2>
        <button class="arrow-left" onclick="moveSlider('left', 'movieSlider2')">←</button>
        <div class="genre-container">
            <div class="movie-slider" id="movieSlider2">
                <% 
                    try {
                        fetchMovies("https://api.themoviedb.org/3/discover/movie?language=ko-KR&sort_by=popularity.desc&page=1", 
                        "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g", out);
                    } catch (Exception e) {
                        out.println("<p>영화를 가져오는 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
                    }
                %>
            </div>
        </div>
        <button class="arrow-right" onclick="moveSlider('right', 'movieSlider2')">→</button>
    </div>

    <div class="category-container">
        <h2 class="main-title">나~지금 센치해  음악 영화 추천 🎶</h2>
        <button class="arrow-left" onclick="moveSlider('left', 'movieSlider4')">←</button>
        <div class="genre-container">
            <div class="movie-slider" id="movieSlider4">
                <% 
                try {
                    fetchMovies("https://api.themoviedb.org/3/discover/movie?language=ko-KR&sort_by=popularity.desc&page=1&with_genres=10402", 
                    "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g", out);
                } catch (Exception e) {
                    out.println("<p>영화를 가져오는 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
                }
                %>
            </div>
        </div>
        <button class="arrow-right" onclick="moveSlider('right', 'movieSlider4')">→</button>
    </div>

    <script src="/JS/main.js"></script>  <!-- 스크립트 파일 추가 -->
</body>
</html>
