package com.quizmaster.controller;

import com.quizmaster.dao.StudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("studentId") != null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String department = request.getParameter("department");
        String yearParam = request.getParameter("year");

        if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                yearParam == null || yearParam.trim().isEmpty()) {

            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        int year = 1;
        try {
            year = Integer.parseInt(yearParam.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Year must be a valid number.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (studentDAO.emailExists(email.trim())) {
            request.setAttribute("error", "An account with this email address already exists. Please log in.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        boolean registered = studentDAO.registerStudent(
                name.trim(),
                email.trim(),
                password,
                department != null ? department.trim() : "",
                year
        );

        if (registered) {
            response.sendRedirect("login.jsp?registered=true");
        } else {
            request.setAttribute("error", "Registration failed due to a database issue. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}