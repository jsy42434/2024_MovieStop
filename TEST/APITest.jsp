<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.BufferedReader, java.io.InputStreamReader, java.net.HttpURLConnection, java.net.URL" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>TMDB API 테스트</title>
</head>
<body>
    <h1>TMDB API 테스트</h1>
    <%
        // API 호출을 위한 URL 및 헤더 설정
        String apiUrl = "https://api.themoviedb.org/3/movie/popular?language=ko-KR&page=1";
        String bearerToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyOGUyYzNhZDNkNGE3ZjExZGNhMDViZTA3ZjBlMmViNyIsIm5iZiI6MTczMzI3OTE5OS4yNTIsInN1YiI6IjY3NGZiZGRmMzU1ZGJjMGIxNWQ3OWMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AjucRR2Izf1HKRwFdBAEPeD8qOaxTHdP02lZenUzZ4g";

        try {
            // URL 연결
            URL url = new URL(apiUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("Authorization", bearerToken);

            // 응답 처리
            int responseCode = connection.getResponseCode();
            if (responseCode == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
                StringBuilder responseBuilder = new StringBuilder(); // 변수명 변경
                String line;

                while ((line = reader.readLine()) != null) {
                    responseBuilder.append(line);
                }
                reader.close();

                // JSON 파싱
                JSONObject jsonResponse = new JSONObject(responseBuilder.toString()); // 변수명 변경
                JSONArray results = jsonResponse.getJSONArray("results");

                // 영화 정보 출력
                out.println("<h2>인기 영화 목록</h2>");
                out.println("<ul>");
                for (int i = 0; i < results.length(); i++) {
                    JSONObject movie = results.getJSONObject(i);
                    String title = movie.getString("title");
                    String posterPath = movie.getString("poster_path");
                    String fullPosterPath = "https://image.tmdb.org/t/p/w500" + posterPath;

                    out.println("<li>");
                    out.println("<img src='" + fullPosterPath + "' alt='" + title + " 포스터' style='width:150px;'>");
                    out.println("<p>" + title + "</p>");
                    out.println("</li>");
                }
                out.println("</ul>");
            } else {
                out.println("<p>API 호출 실패: 응답 코드 " + responseCode + "</p>");
            }
        } catch (Exception e) {
            out.println("<p>오류 발생: " + e.getMessage() + "</p>");
        }
    %>
</body>
</html>