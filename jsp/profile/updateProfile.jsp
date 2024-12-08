<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String updateType = request.getParameter("type");
    String userId = (String)session.getAttribute("userId");
    String message = "";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String dbUrl = "jdbc:mysql://175.106.96.150:3306/movie_project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String dbUser = "root";
        String dbPassword = "Movie1234!";
        
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        
        switch(updateType) {
            case "id": {
                String currentId = request.getParameter("current_id");
                String newId = request.getParameter("new_id");
                
                System.out.println("\n=== ID Update Debug Log ===");
                System.out.println("1. Parameters received:");
                System.out.println("- Current ID: " + currentId);
                System.out.println("- New ID: " + newId);
                System.out.println("- Session userId: " + userId);
                
                if (!currentId.equals(userId)) {
                    System.out.println("2. Error: Current ID doesn't match session ID");
                    message = "id_wrong";
                } else {
                    try {
                        System.out.println("3. Checking for duplicate ID");
                        pstmt = conn.prepareStatement("SELECT id FROM users WHERE id = ?");
                        pstmt.setString(1, newId);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            System.out.println("4. Error: New ID already exists");
                            message = "id_duplicate";
                        } else {
                            System.out.println("5. Starting ID update process");
                            conn.setAutoCommit(false);
                            
                            try {
                                // 1. 외래 키 제약 조건 일시 해제
                                System.out.println("6. Disabling foreign key checks");
                                Statement stmt = conn.createStatement();
                                stmt.execute("SET FOREIGN_KEY_CHECKS=0");
                                
                                // 2. 모든 테이블 업데이트
                                System.out.println("7. Updating all tables");
                                
                                // users 테이블 업데이트
                                pstmt = conn.prepareStatement("UPDATE users SET id = ? WHERE id = ?");
                                pstmt.setString(1, newId);
                                pstmt.setString(2, currentId);
                                int userResult = pstmt.executeUpdate();
                                
                                // favorite 테이블 업데이트
                                pstmt = conn.prepareStatement("UPDATE favorite SET user_id = ? WHERE user_id = ?");
                                pstmt.setString(1, newId);
                                pstmt.setString(2, currentId);
                                pstmt.executeUpdate();
                                
                                // review 테이블 업데이트
                                pstmt = conn.prepareStatement("UPDATE review SET user_id = ? WHERE user_id = ?");
                                pstmt.setString(1, newId);
                                pstmt.setString(2, currentId);
                                pstmt.executeUpdate();
                                
                                // 3. 외래 키 제약 조건 복원
                                System.out.println("8. Enabling foreign key checks");
                                stmt.execute("SET FOREIGN_KEY_CHECKS=1");
                                
                                if (userResult > 0) {
                                    System.out.println("9. All updates successful");
                                    session.setAttribute("userId", newId);
                                    conn.commit();
                                    message = "id_success";
                                } else {
                                    System.out.println("10. Error: Update failed");
                                    conn.rollback();
                                    message = "error";
                                }
                                
                                stmt.close();
                            } catch (SQLException e) {
                                System.out.println("11. SQL Error: " + e.getMessage());
                                e.printStackTrace();
                                conn.rollback();
                                // 에러 발생 시에도 외래 키 체크 복원
                                Statement stmt = conn.createStatement();
                                stmt.execute("SET FOREIGN_KEY_CHECKS=1");
                                stmt.close();
                                message = "error";
                            }
                        }
                    } catch (SQLException e) {
                        System.out.println("12. Database Error: " + e.getMessage());
                        e.printStackTrace();
                        message = "error";
                    } finally {
                        try {
                            conn.setAutoCommit(true);
                            System.out.println("13. Transaction completed. Message: " + message);
                        } catch (SQLException e) {
                            System.out.println("14. Error resetting autocommit: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                }
                break;
            }
            
            case "password": {
                String currentPassword = request.getParameter("current_password");
                String newPassword = request.getParameter("new_password");
                String confirmPassword = request.getParameter("confirm_password");
                
                // 1. 새 비밀번호 확인
                if (!newPassword.equals(confirmPassword)) {
                    message = "pw_mismatch";
                    break;
                }
                
                // 2. 현재 비밀번호 확인
                String inputHashedPassword = org.apache.commons.codec.digest.DigestUtils.sha256Hex(currentPassword);
                String hashedNewPassword = org.apache.commons.codec.digest.DigestUtils.sha256Hex(newPassword);
                
                pstmt = conn.prepareStatement("SELECT id FROM users WHERE id = ? AND pw = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, inputHashedPassword);
                rs = pstmt.executeQuery();
                
                if (!rs.next()) {
                    message = "pw_wrong";
                    break;
                }
                
                // 3. 비밀번호 업데이트
                String updateQuery = "UPDATE users SET pw = ? WHERE id = ?";
                pstmt = conn.prepareStatement(updateQuery);
                pstmt.setString(1, hashedNewPassword);
                pstmt.setString(2, userId);
                int updateResult = pstmt.executeUpdate();
                
                if (updateResult > 0) {
                    message = "pw_success";
                } else {
                    message = "pw_wrong";
                }
                break;
            }
            
            case "nickname": {
                String newNickname = request.getParameter("new_nickname");
                pstmt = conn.prepareStatement("UPDATE users SET nickname = ? WHERE id = ?");
                pstmt.setString(1, newNickname);
                pstmt.setString(2, userId);
                int nicknameResult = pstmt.executeUpdate();
                
                if(nicknameResult > 0) {
                    message = "nickname_success";
                } else {
                    message = "nickname_error";
                }
                break;
            }
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        message = "error";
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    response.sendRedirect("profile_change.jsp?update=" + message);
%>