<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/style/login-style.css">
    <title>회원가입 화면</title>
    <script>
        window.onload = function () {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('error')) {
                const errorCode = urlParams.get('error');
                let errorMessage;

                switch (errorCode) {
                    case 'id_exists': // 이미 사용 중인 아이디
                        errorMessage = "이미 사용 중인 아이디입니다.";
                        break;
                    case 'id_length': // 아이디 길이 오류
                        errorMessage = "아이디는 4~16자 사이여야 합니다.";
                        break;
                    case 'password_mismatch': // 비밀번호 불일치
                        errorMessage = "비밀번호와 비밀번호 확인이 일치하지 않습니다.";
                        break;
                    case 'weak_password': // 비밀번호 약함
                        errorMessage = "비밀번호는 8~16자, 영문자와 특수문자가 포함되어야 합니다.";
                        break;
                    case 'database': //데이터베이스 업데이트 못했을 때
                        errorMessage = "데이터베이스에 오류가 발생했습니다.";
                        break;
                    default:
                        errorMessage = "알 수 없는 오류가 발생했습니다.";
                }
                alert(errorMessage);
            }
        }
    </script>
</head>

<body>
    <jsp:include page="/jsp/home/nav.jsp"/>

    <!-- 회원가입 화면 영역 -->
        <section class="login-form">
            <form action="signupProcess.jsp" method="post">
                <input type="text" id="username" name="username" placeholder="아이디(4~16글자)" required />
                <input type="password" id="password" name="password" placeholder="비밀번호(8~16글자의 영문, 특수문자 조합)" required />
                <input type="password" id="confirm_password" name="confirm_password" placeholder="비밀번호 확인" required />
                <input type="text" id="nickname" name="nickname" placeholder="닉네임" required />
                <button type="submit">회원가입</button>
            </form>
            <div class="links">
                <a href="/jsp/login/login.jsp">로그인</a>
            </div>
        </section>
</body>

</html>
