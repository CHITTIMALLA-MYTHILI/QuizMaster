package com.quizmaster.controller;

import com.quizmaster.dao.AdminDAO;
import com.quizmaster.model.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/adminLogin")
public class AdminLoginServlet extends HttpServlet {

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminLoggedIn") != null) {
            response.sendRedirect("admin-dashboard");
            return;
        }

        request.getRequestDispatcher("admin-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required.");
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
            return;
        }

        boolean valid = adminDAO.validateAdmin(username.trim(), password);

        if (valid) {
            HttpSession session = request.getSession(true);
            Admin admin = adminDAO.getAdminByUsername(username.trim());
            int adminId = (admin != null) ? admin.getAdminId() : 1;

            session.setAttribute("adminUsername", username.trim());
            session.setAttribute("adminId", adminId);
            session.setAttribute("adminLoggedIn", true);

            response.sendRedirect("admin-dashboard");
        } else {
            request.setAttribute("error", "Invalid username or password.");
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
        }
    }
}