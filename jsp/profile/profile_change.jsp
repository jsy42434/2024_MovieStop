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
    <link rel="stylesheet" href="/style/profile/profile_change_style.css">
    <script>
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('update')) {
                const updateStatus = urlParams.get('update');
                switch(updateStatus) {
                    case 'id_wrong':
                        alert('현재 아이디가 일치하지 않습니다.');
                        showForm('id');
                        break;
                    case 'id_duplicate':
                        alert('이미 사용 중인 아이디입니다.');
                        showForm('id');
                        break;
                    case 'id_success':
                        alert('아이디가 성공적으로 변경되었습니다.');
                        break;
                    case 'pw_wrong':
                        alert('현재 비밀번호가 일치하지 않습니다.');
                        showForm('password');
                        break;
                    case 'pw_mismatch':
                        alert('새 비밀번호가 일치하지 않습니다.');
                        showForm('password');
                        break;
                    case 'pw_success':
                        alert('비밀번호가 성공적으로 변경되었습니다.');
                        break;
                    case 'nickname_success':
                        alert('닉네임이 성공적으로 변경되었습니다.');
                        break;
                    case 'error':
                        alert('처리 중 오류가 발생했습니다. 다시 시도해주세요.');
                        break;
                    default:
                        alert('알 수 없는 오류가 발생했습니다. 다시 시도해주세요.');
                        break;
                }
            }
        }
    </script>
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
                    
                    // 세션에서 userId 가져오기
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
    
    <div class="profile-update-container">
        <div class="button-group">
            <button onclick="showForm('id')" class="change-button">아이디 변경</button>
            <button onclick="showForm('password')" class="change-button">비밀번호 변경</button>
            <button onclick="showForm('nickname')" class="change-button">닉네임 변경</button>
        </div>

        <div id="idForm" class="update-section" style="display: none;">
            <h3>아이디 변경</h3>
            <form action="updateProfile.jsp" method="post">
                <input type="hidden" name="type" value="id">
                <input type="text" name="current_id" placeholder="현재 아이디" required>
                <input type="text" name="new_id" placeholder="새로운 아이디" required>
                <div class="form-buttons">
                    <button type="submit">변경</button>
                    <button type="button" onclick="hideForm('id')">취소</button>
                </div>
            </form>
        </div>

        <div id="passwordForm" class="update-section" style="display: none;">
            <h3>비밀번호 변경</h3>
            <form action="updateProfile.jsp" method="post">
                <input type="hidden" name="type" value="password">
                <input type="password" name="current_password" placeholder="현재 비밀번호" required>
                <input type="password" name="new_password" placeholder="새로운 비밀번호" required>
                <input type="password" name="confirm_password" placeholder="비밀번호 확인" required>
                <div class="form-buttons">
                    <button type="submit">변경</button>
                    <button type="button" onclick="hideForm('password')">취소</button>
                </div>
            </form>
        </div>

        <div id="nicknameForm" class="update-section" style="display: none;">
            <h3>닉네임 변경</h3>
            <form action="updateProfile.jsp" method="post">
                <input type="hidden" name="type" value="nickname">
                <input type="text" name="new_nickname" placeholder="새로운 닉네임" required>
                <div class="form-buttons">
                    <button type="submit">변경</button>
                    <button type="button" onclick="hideForm('nickname')">취소</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function showForm(type) {
            // 모든 폼 숨기기
            document.getElementById('idForm').style.display = 'none';
            document.getElementById('passwordForm').style.display = 'none';
            document.getElementById('nicknameForm').style.display = 'none';
            
            // 선택된 폼만 보이기
            document.getElementById(type + 'Form').style.display = 'block';
        }

        function hideForm(type) {
            document.getElementById(type + 'Form').style.display = 'none';
        }

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