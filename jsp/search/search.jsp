<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader, java.io.InputStreamReader, java.net.HttpURLConnection, java.net.URL" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영화 검색</title>
    <link rel="stylesheet" href="/style/home/nav-style.css">
    <link rel="stylesheet" href="/style/search-style.css">
</head>
<body>
    <div id="navigation">
        <jsp:include page="/jsp/home/nav.jsp" />
    </div>

    <div class="search-page-container">
        <h2 class="search-title">영화 검색</h2>
        
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

            const resultGrid = document.getElementById('resultGrid');
            const noResults = document.getElementById('noResults');
            
            let apiUrl = searchType === 'movie' 
                ? '/jsp/search/search_movies.jsp?query=' + encodeURIComponent(searchTerm)
                : '/jsp/search/search_people.jsp?query=' + encodeURIComponent(searchTerm);
            
            fetch(apiUrl)
                .then(response => response.text())
                .then(data => {
                    if (data.includes('no-results')) {
                        resultGrid.style.display = 'none';
                        noResults.style.display = 'block';
                    } else {
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