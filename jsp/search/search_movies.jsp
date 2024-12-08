<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, org.json.*, java.util.*" %>
<%
    String query = request.getParameter("query");
    String apiUrl = "https://api.themoviedb.org/3/search/movie?language=ko-KR&query=" + 
                    URLEncoder.encode(query, "UTF-8") + "&page=1";
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

        JSONObject jsonResponse = new JSONObject(responseBuilder.toString());
        JSONArray results = jsonResponse.getJSONArray("results");

        if (results.length() == 0) {
            out.print("<div class='no-results'>no-results</div>");
            return;
        }

        List<JSONObject> allMovies = new ArrayList<>();
        for (int i = 0; i < results.length(); i++) {
            JSONObject movie = results.getJSONObject(i);
            if (!movie.optString("poster_path", "").equals("")) {
                allMovies.add(movie);
            }
        }

        int totalMovies = allMovies.size();

        for (JSONObject movie : allMovies) {
            String title = movie.getString("title");
            String posterPath = movie.getString("poster_path");
            int movieId = movie.getInt("id");
            String fullPosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;
%>
            <div class="result-item" onclick="location.href='/jsp/movie/movie_information.jsp?movie_id=<%= movieId %>'">
                <img src="<%= fullPosterPath %>" alt="<%= title %>" class="result-poster">
                <p class="result-title"><%= title %></p>
            </div>
<%
        }

    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    }
%>