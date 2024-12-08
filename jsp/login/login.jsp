<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/style/login-style.css">
    <title>로그인 화면</title>
        <script>
        window.onload = function () {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('signup')) {
                const signupCode = urlParams.get('signup');
                if (signupCode=='success')
                alert("회원가입이 성공적으로 완료되었습니다.\n로그인 화면으로 이동합니다.");
            }
                        // 로그인 오류 메시지 처리
            if (urlParams.has('error')) {
                const errorMessage = urlParams.get('error');
                switch (errorMessage) {
                    case 'password_incorrect':
                        alert("비밀번호가 올바르지 않습니다. 다시 시도해 주세요.");
                        break;
                    case 'user_not_found':
                        alert("사용자를 찾을 수 없습니다. 다시 확인해 주세요.");
                        break;
                    default:
                        alert(errorMessage);
                }
            }
        }
    </script>
</head>

<body>
        <jsp:include page="/jsp/home/nav.jsp"/>
    
    <!-- 로그인 화면 영역 -->
        <section class="login-form">
            <form action="loginProcess.jsp" method="post">
                <input type="text" id="username" name="username" placeholder="아이디" required />
                <input type="password" id="password" name="password" placeholder="비밀번호" required />
                <button type="submit">로그인</button>
            </form>
            <div class="links">
                <a href="../signup/signup.jsp">회원가입</a>
            </div>
        </section>
</body>

</html>
