<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader, java.io.InputStreamReader, java.net.HttpURLConnection, java.net.URL" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>장르_액니메이션</title>
    <link rel="stylesheet" href="/style/home/nav-style.css">
    <link rel="stylesheet" href="/style/search-style.css">
    <link rel="stylesheet" href="/style/genre/animation_style.css">
</head>
<body>
    <div id="navigation">
        <jsp:include page="/jsp/home/nav.jsp" />
    </div>

    <div class="search-page-container">
        <h2 class="category-title">애니메이션</h2>
        
        <div class="search-options">
            <select id="searchType" class="search-type">
                <option value="movie">영화 제목</option>
                <option value="person">감독/배우</option>
            </select>
            <div class="search-input-container">
                <input type="text" class="search-bar" id="searchInput" placeholder="검색어를 입력하세요">
                <button class="search-button" onclick="performSearch()">🔍</button>
            </div>
        </div>
        
        <div id="noResults" style="display: none; text-align: center; color: #fff; margin: 20px;">
            검색 결과가 없습니다.
        </div>
        
        <div class="result-grid" id="resultGrid"></div>
        
        <div class="movie-grid" id="movieGrid">
            <%
                String apiUrl = "https://api.themoviedb.org/3/discover/movie?with_genres=16&language=ko-KR&page=1";
                String bearerToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g";

                try {
                    URL url = new URL(apiUrl);
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("GET");
                    connection.setRequestProperty("Accept", "application/json");
                    connection.setRequestProperty("Authorization", bearerToken);

                    BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;

                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    reader.close();

                    JSONObject firstResponse = new JSONObject(responseBuilder.toString());
                    int totalPages = firstResponse.getInt("total_pages");
                    totalPages = Math.min(totalPages, 10);

                    for (int pageNum = 1; pageNum <= totalPages; pageNum++) {
                        String pageUrl = "https://api.themoviedb.org/3/discover/movie?with_genres=16&language=ko-KR&page=" + pageNum;
                        url = new URL(pageUrl);
                        connection = (HttpURLConnection) url.openConnection();
                        connection.setRequestMethod("GET");
                        connection.setRequestProperty("Accept", "application/json");
                        connection.setRequestProperty("Authorization", bearerToken);

                        reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
                        responseBuilder = new StringBuilder();

                        while ((line = reader.readLine()) != null) {
                            responseBuilder.append(line);
                        }
                        reader.close();

                        JSONObject jsonResponse = new JSONObject(responseBuilder.toString());
                        JSONArray results = jsonResponse.getJSONArray("results");

                        for (int i = 0; i < results.length(); i++) {
                            JSONObject movie = results.getJSONObject(i);
                            String title = movie.getString("title");
                            String posterPath = movie.getString("poster_path");
                            if (posterPath == null || posterPath.equals("null") || posterPath.isEmpty()) {
                                continue;
                            }
                            int movieId = movie.getInt("id");
                            String fullPosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;
            %>
                            <div class="movie-item" onclick="location.href='/jsp/movie/movie_information.jsp?movie_id=<%= movieId %>'">
                                <img src="<%= fullPosterPath %>" alt="<%= title %>" class="movie-poster">
                                <p class="movie-title"><%= title %></p>
                            </div>
            <%
                        }
                    }
                } catch (Exception e) {
                    out.println("<p>오류 발생: " + e.getMessage() + "</p>");
                }
            %>
        </div>
    </div>

    <script>
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                performSearch();
            }
        });

        function performSearch() {
            const searchTerm = document.getElementById('searchInput').value.trim();
            const searchType = document.getElementById('searchType').value;
            if (searchTerm === '') return;

            const movieGrid = document.getElementById('movieGrid');
            const resultGrid = document.getElementById('resultGrid');
            const noResults = document.getElementById('noResults');
            
            let apiUrl = searchType === 'movie' 
                ? '/jsp/search/search_movies.jsp?query=' + encodeURIComponent(searchTerm)
                : '/jsp/search/search_people.jsp?query=' + encodeURIComponent(searchTerm);
            
            fetch(apiUrl)
                .then(response => response.text())
                .then(data => {
                    if (data.includes('no-results')) {
                        movieGrid.style.display = 'none';
                        resultGrid.style.display = 'none';
                        noResults.style.display = 'block';
                    } else {
                        movieGrid.style.display = 'none';
                        resultGrid.style.display = 'grid';
                        noResults.style.display = 'none';
                        resultGrid.innerHTML = data;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('검색 중 오류가 발생했습니다.');
                });
        }
    </script>
</body>
</html>

</```rewritten_file>