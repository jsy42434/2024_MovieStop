<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, org.json.*, java.sql.*" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/style/movie/movie_information-style.css">
    <title>영화 정보</title>
</head>

<body>
    <jsp:include page="/jsp/home/nav.jsp"/>
    <section class="container">
    <%
        // URL 파라미터에서 movie_id 가져오기
        String movieId = request.getParameter("movie_id");
        if (movieId == null || movieId.trim().isEmpty()) {
            //movieId = "558449"; // 기본값 설정 (테스트 용)
        }
        String userId = (String) session.getAttribute("userId"); // 세션에서 사용자 ID 가져오기
        String nickname = (String) session.getAttribute("nickname"); // 세션에서 닉네임 가져오기
        if(nickname==null){
            nickname = "로그인 후 댓글을 달 수 있습니다.";
        }
        // 변수 선언
        String title = "정보 없음";
        String director = "정보 없음";
        String genre = "정보 없음";
        String rating = "정보 없음";
        String posterPath = "";
        String overview = "정보 없음";
        String releaseDate = "정보 없음";
        String ageRating = "정보 없음";
        
        // API 호출 및 데이터 처리
        String movieApiUrl = "https://api.themoviedb.org/3/movie/" + movieId + "?language=ko-KR";
        String creditsApiUrl = "https://api.themoviedb.org/3/movie/" + movieId + "/credits?language=ko-KR";
        String bearerToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g";

        try {
            // 영화 기본 정보 가져오기
            URL movieUrl = new URL(movieApiUrl);
            HttpURLConnection movieConnection = (HttpURLConnection) movieUrl.openConnection();
            movieConnection.setRequestMethod("GET");
            movieConnection.setRequestProperty("Accept", "application/json");
            movieConnection.setRequestProperty("Authorization", bearerToken);

            int movieResponseCode = movieConnection.getResponseCode();
            if (movieResponseCode == 200) {
                BufferedReader movieReader = new BufferedReader(new InputStreamReader(movieConnection.getInputStream(), "UTF-8"));
                StringBuilder movieResponseBuilder = new StringBuilder();
                String movieLine;

                while ((movieLine = movieReader.readLine()) != null) {
                    movieResponseBuilder.append(movieLine);
                }
                movieReader.close();

                JSONObject movieData = new JSONObject(movieResponseBuilder.toString());
                title = movieData.getString("title");
                genre = movieData.getJSONArray("genres").getJSONObject(0).getString("name");
                rating = movieData.optString("vote_average", "평점 없음");
                posterPath = "https://image.tmdb.org/t/p/w500" + movieData.getString("poster_path");
                overview = movieData.getString("overview");
                releaseDate = movieData.getString("release_date");
                if(overview == null){
                    overview = "등록된 줄거리가 없습니다.";
                }

                //평점 소숫점 첫째 자리까지 반올림
                try {
                    double voteAverage = Double.parseDouble(rating);
                    rating = String.format("%.1f", voteAverage); // 소숫점 첫째 자리까지 반올림
                } catch (NumberFormatException e) {
                    // "평점 없음"과 같은 문자열이 있을 경우 예외 처리
                    rating = "평점 없음";
                }
                
                // Release dates 엔드포인트 호출
                String releaseDatesApiUrl = "https://api.themoviedb.org/3/movie/" + movieId + "/release_dates?language=ko-KR";
                URL releaseDatesUrl = new URL(releaseDatesApiUrl);
                HttpURLConnection releaseDatesConnection = (HttpURLConnection) releaseDatesUrl.openConnection();
                releaseDatesConnection.setRequestMethod("GET");
                releaseDatesConnection.setRequestProperty("Accept", "application/json");
                releaseDatesConnection.setRequestProperty("Authorization", bearerToken);

                int releaseDatesResponseCode = releaseDatesConnection.getResponseCode();
                if (releaseDatesResponseCode == 200) {
                    BufferedReader releaseDatesReader = new BufferedReader(new InputStreamReader(releaseDatesConnection.getInputStream(), "UTF-8"));
                    StringBuilder releaseDatesResponseBuilder = new StringBuilder();
                    String releaseDatesLine;

                    while ((releaseDatesLine = releaseDatesReader.readLine()) != null) {
                        releaseDatesResponseBuilder.append(releaseDatesLine);
                    }
                    releaseDatesReader.close();

                    JSONObject releaseDatesData = new JSONObject(releaseDatesResponseBuilder.toString());
                    JSONArray results = releaseDatesData.getJSONArray("results");

                    // 연령 제한 정보 가져오기 (한국 기준)
                    for (int i = 0; i < results.length(); i++) {
                        JSONObject countryData = results.getJSONObject(i);
                        if (countryData.getString("iso_3166_1").equals("KR")) { // 한국(KR) 기준
                            JSONArray releaseDates = countryData.getJSONArray("release_dates");
                            for (int j = 0; j < releaseDates.length(); j++) {
                                JSONObject releaseInfo = releaseDates.getJSONObject(j);
                                ageRating = releaseInfo.optString("certification", "연령 제한 정보 없음");
                                break;
                            }
                            break;
                        }
                    }
                } else {
                    ageRating = "정보 없음";
                }
            }

            // 감독 정보 가져오기
            URL creditsUrl = new URL(creditsApiUrl);
            HttpURLConnection creditsConnection = (HttpURLConnection) creditsUrl.openConnection();
            creditsConnection.setRequestMethod("GET");
            creditsConnection.setRequestProperty("Accept", "application/json");
            creditsConnection.setRequestProperty("Authorization", bearerToken);

            int creditsResponseCode = creditsConnection.getResponseCode();
            if (creditsResponseCode == 200) {
                BufferedReader creditsReader = new BufferedReader(new InputStreamReader(creditsConnection.getInputStream(), "UTF-8"));
                StringBuilder creditsResponseBuilder = new StringBuilder();
                String creditsLine;

                while ((creditsLine = creditsReader.readLine()) != null) {
                    creditsResponseBuilder.append(creditsLine);
                }
                creditsReader.close();

                JSONObject creditsData = new JSONObject(creditsResponseBuilder.toString());
                JSONArray crew = creditsData.getJSONArray("crew");
                for (int i = 0; i < crew.length(); i++) {
                    JSONObject member = crew.getJSONObject(i);
                    if (member.getString("job").equalsIgnoreCase("Director")) {
                        director = member.getString("name");
                        break;
                    }
                }
            }
        } catch (Exception e) {
            // 오류 발생 시 JavaScript를 이용한 alert 메시지 출력
            out.println("<script>alert('오류 발생: " + e.getMessage() + "');</script>");
        }
    %>
    <div class="movie-header">
        <img src="<%= posterPath %>" alt="<%= title %> 포스터">
        <div class="movie-info">
            <h1><%= title %></h1>
            <p><strong>감독:</strong> <%= director %></p>
            <p><strong>장르:</strong> <%= genre %></p>
            <p><strong>개봉일:</strong> <%= releaseDate %></p>
            <p><strong>연령제한:</strong> <%= ageRating %></p>
            <p><strong>평점:</strong> <%= rating %></p>
        </div>
        <form action="/jsp/movie/movie_favorite.jsp" method="post">
            <input type="hidden" name="user_id" value="<%= userId %>">
            <input type="hidden" name="movie_id" value="<%= movieId %>">
            <button type="submit" class="favorite-btn">찜 하기</button>
        </form>
    </div>
    <div class="summary">
        <p><%= overview %></p>
    </div>
        </section>
        <section class="container">
            <h3>리뷰 목록</h3>
                <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/movie_project?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8",
                            "root",
                            "Movie1234!"
                        );
                        String sql = "SELECT u.nickname, r.review_content, r.review_star " +
                                    "FROM review r " +
                                    "JOIN users u ON r.user_id = u.id " +
                                    "WHERE r.movie_id = ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, movieId);
                        rs = pstmt.executeQuery();

                        while (rs.next()) {
                %>
                <div class="review">
                    <div class="review-header">
                        <strong><%= rs.getString("nickname") %></strong>
                        <span class="review-rating">
                            <% for (int i = 0; i < rs.getInt("review_star"); i++) out.print("⭐"); %>
                        </span>
                    </div>
                    <div class="review-text">
                        <%= rs.getString("review_content") %>
                    </div>
                </div>
                <% } %>
                <%
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
                    }
                %>
        </section>

    <section class="container">
        <form action="/jsp/movie/save_review.jsp" method="post" accept-charset="UTF-8">
            <h3>리뷰 작성</h3>
            <div class="review-header">
                <span class="nickname"><%= nickname %></span>
                <div class="stars" id="stars">
                    <span data-value="1">★</span>
                    <span data-value="2">★</span>
                    <span data-value="3">★</span>
                    <span data-value="4">★</span>
                    <span data-value="5">★</span>
                </div>
            </div>
            <input type="hidden" name="user_id" value="<%= userId %>">
            <input type="hidden" name="movie_id" value="<%= movieId %>">
            <input type="hidden" id="review_star" name="review_star">
            <textarea class="review-textarea" name="review_content" placeholder="리뷰를 작성해주세요." required></textarea>
            <button type="submit" class="submit-btn">등록</button>
        </form>
    </section>

<script>
    const stars = document.querySelectorAll('#stars span');
    const starInput = document.getElementById('review_star');

    function updateStars(index, className) {
        stars.forEach((s, i) => {
            s.classList.toggle(className, i <= index);
        });
        if (className === 'selected') {
            starInput.value = index + 1; // 선택된 별점 값을 hidden input에 설정
        }
    }

    stars.forEach((star, index) => {
        star.addEventListener('mouseover', () => updateStars(index, 'hovered'));
        star.addEventListener('click', () => updateStars(index, 'selected'));
    });

    document.getElementById('stars').addEventListener('mouseleave', () => {
        stars.forEach(star => star.classList.remove('hovered'));
    });
</script>


</body>

</html>