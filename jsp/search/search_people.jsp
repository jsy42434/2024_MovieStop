<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, org.json.*" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%
    String query = request.getParameter("query");
    String searchPersonUrl = "https://api.themoviedb.org/3/search/person?language=ko-KR&query=" + URLEncoder.encode(query, "UTF-8");
    String bearerToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g";

    try {
        URL searchUrl = new URL(searchPersonUrl);
        HttpURLConnection searchConn = (HttpURLConnection) searchUrl.openConnection();
        searchConn.setRequestMethod("GET");
        searchConn.setRequestProperty("Authorization", bearerToken);
        searchConn.setRequestProperty("Accept", "application/json");

        BufferedReader searchBr = new BufferedReader(new InputStreamReader(searchConn.getInputStream(), "UTF-8"));
        StringBuilder searchResponseBuilder = new StringBuilder();
        String line;
        while ((line = searchBr.readLine()) != null) {
            searchResponseBuilder.append(line);
        }
        searchBr.close();

        JSONObject searchResponse = new JSONObject(searchResponseBuilder.toString());
        JSONArray searchResults = searchResponse.getJSONArray("results");

        if (searchResults.length() == 0) {
            out.print("<div class='no-results'>no-results</div>");
            return;
        }

        int personId = searchResults.getJSONObject(0).getInt("id");
        String personName = searchResults.getJSONObject(0).getString("name");

        String creditsUrl = "https://api.themoviedb.org/3/person/" + personId + "/movie_credits?language=ko-KR";
        URL url = new URL(creditsUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", bearerToken);
        conn.setRequestProperty("Accept", "application/json");

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
        StringBuilder responseBuilder = new StringBuilder();
        while ((line = br.readLine()) != null) {
            responseBuilder.append(line);
        }
        br.close();

        JSONObject creditsResponse = new JSONObject(responseBuilder.toString());
        
        // 배우로서의 출연작
        JSONArray castMovies = creditsResponse.optJSONArray("cast");
        // 감독/제작진으로서의 작품
        JSONArray crewMovies = creditsResponse.optJSONArray("crew");

        List<JSONObject> allMovies = new ArrayList<>();
        
        if (castMovies != null) {
            for (int i = 0; i < castMovies.length(); i++) {
                JSONObject movie = castMovies.getJSONObject(i);
                if (!movie.optString("poster_path", "").equals("")) {
                    allMovies.add(movie);
                }
            }
        }

        if (crewMovies != null) {
            for (int i = 0; i < crewMovies.length(); i++) {
                JSONObject movie = crewMovies.getJSONObject(i);
                if (!movie.optString("poster_path", "").equals("")) {
                    // 중복 체크
                    boolean isDuplicate = false;
                    for (JSONObject existingMovie : allMovies) {
                        if (existingMovie.getInt("id") == movie.getInt("id")) {
                            isDuplicate = true;
                            break;
                        }
                    }
                    if (!isDuplicate) {
                        allMovies.add(movie);
                    }
                }
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

        if (allMovies.isEmpty()) {
            out.print("<div class='no-results'>no-results</div>");
        }

    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    }
%> 