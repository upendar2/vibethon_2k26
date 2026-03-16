package com.example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;



@WebServlet("/studentRegistration")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,   // 1MB
    maxFileSize = 1024 * 1024 * 5,      // 5MB
    maxRequestSize = 1024 * 1024 * 20    // 20MB
)
public class StudentRegistration extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/plain");
        PrintWriter out = res.getWriter();
        Connection con = null;
        PreparedStatement psStudentDetails = null;

        try {
            // 1. Capture All Fields
            String name = req.getParameter("fullname");
            String regdno = req.getParameter("regdno");
            String fathername = req.getParameter("fathername");
            String mothername = req.getParameter("mothername");
            String admno = req.getParameter("admno");
            String rankStr = req.getParameter("rank");
            String adtype = req.getParameter("admtype");
            String joincate = req.getParameter("joincate");
            String joinyear = req.getParameter("joinyear");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String gender = req.getParameter("gender");
            String village = req.getParameter("village");
            String mandal = req.getParameter("mandal");
            String dist = req.getParameter("dist");
            String dept = req.getParameter("dept");
            String clas = req.getParameter("class");
            String pincodeStr = req.getParameter("pincode");
            String password = req.getParameter("password");
            String dateStr = req.getParameter("date");
            String monthStr = req.getParameter("month");
            String yearStr = req.getParameter("year");

            // 2. Validation & Parsing
            if (name == null || regdno == null || email == null || password == null) {
                throw new IllegalArgumentException("Essential fields (Name, RegdNo, Email, Password) are missing.");
            }

            int rank = Integer.parseInt(rankStr.trim());
            int pincode = Integer.parseInt(pincodeStr.trim());
            int joinyearInt = Integer.parseInt(joinyear.trim());
            LocalDate dob = LocalDate.of(Integer.parseInt(yearStr), Integer.parseInt(monthStr), Integer.parseInt(dateStr));

            // 3. Handle Files
            byte[] photoBytes = null;
            byte[] signBytes = null;
            Part photoPart = req.getPart("photo");
            Part signPart = req.getPart("sign");

            if (photoPart != null && photoPart.getSize() > 0) {
                try (InputStream is = photoPart.getInputStream()) { photoBytes = is.readAllBytes(); }
            }
            if (signPart != null && signPart.getSize() > 0) {
                try (InputStream is = signPart.getInputStream()) { signBytes = is.readAllBytes(); }
            }

            // 4. Database Connection
            con = DbConnection.getConne();
            if (con == null) throw new SQLException("Failed to establish DB connection.");
            con.setAutoCommit(false);

            // 5. Insert Query (22 Fields)
            String sql = "INSERT INTO STUDENTS (REGD_NO, NAME, FATHERNAME, MOTHERNAME, ADMNO, RANK, ADTYPE, JOINCATE, EMAIL, PHONE, DOB, GENDER, VILLAGE, MANDAL, DIST, PINCODE, PHOTO, SIGN, PASSWORD, DEPT, CLASS, JOINYEAR) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            psStudentDetails = con.prepareStatement(sql);

            psStudentDetails.setString(1, regdno.trim());
            psStudentDetails.setString(2, name.trim());
            psStudentDetails.setString(3, fathername);
            psStudentDetails.setString(4, mothername);
            psStudentDetails.setString(5, admno);
            psStudentDetails.setInt(6, rank);
            psStudentDetails.setString(7, adtype);
            psStudentDetails.setString(8, joincate);
            psStudentDetails.setString(9, email.trim());
            psStudentDetails.setString(10, phone);
            psStudentDetails.setDate(11, java.sql.Date.valueOf(dob));
            psStudentDetails.setString(12, gender);
            psStudentDetails.setString(13, village);
            psStudentDetails.setString(14, mandal);
            psStudentDetails.setString(15, dist);
            psStudentDetails.setInt(16, pincode);
            psStudentDetails.setBytes(17, photoBytes);
            psStudentDetails.setBytes(18, signBytes);
            psStudentDetails.setString(19, HashPassword.hashPassword(password));
            psStudentDetails.setString(20, dept);
            psStudentDetails.setString(21, clas);
            psStudentDetails.setInt(22, joinyearInt);

            int rowsAffected = psStudentDetails.executeUpdate();

            if (rowsAffected > 0) {
                con.commit();
                
                // 6. Send Themed Email
                String subject = "Registration Confirmed From Department of INFORMATION TECHNOLOGY AND COMPUTER APPLICATIONS";
                String body = "Dear " + name + ",\n\nYour registration as Student is successful.\nRegd No: " + regdno;
                
                EmailSender.sendEmail(email, subject, body);
                out.write("Registration successful! Confirmation email sent to " + email);
            } else {
                con.rollback();
                out.write("Registration failed: Database did not accept the record.");
            }

        } catch (SQLException e) {
            if (con != null) try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            if ("23505".equals(e.getSQLState())) {
                out.write("Error: Registration Number " + req.getParameter("regdno") + " already exists.");
            } else {
                e.printStackTrace();
                out.write("Database Error: " + e.getMessage());
            }
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            out.write("Error: " + e.getMessage());
        } finally {
            try { if (psStudentDetails != null) psStudentDetails.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}