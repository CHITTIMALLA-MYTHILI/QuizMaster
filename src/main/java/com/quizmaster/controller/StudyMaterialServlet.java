package com.quizmaster.controller;

import com.quizmaster.dao.StudyMaterialDAO;
import com.quizmaster.model.StudyMaterial;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/study-materials")
public class StudyMaterialServlet extends HttpServlet {

    private final StudyMaterialDAO materialDAO = new StudyMaterialDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            String idParam = request.getParameter("materialId");
            if (idParam != null) {
                try {
                    materialDAO.deleteMaterial(Integer.parseInt(idParam));
                } catch (Exception ignored) {}
            }
            response.sendRedirect("study-materials");
            return;
        }

        List<StudyMaterial> materials = materialDAO.getAllMaterials();
        request.setAttribute("materials", materials);
        request.getRequestDispatcher("study-materials.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String contentText = request.getParameter("contentText");

        if (title != null && !title.trim().isEmpty() && contentText != null && !contentText.trim().isEmpty()) {
            Integer adminId = (Integer) session.getAttribute("adminId");
            materialDAO.addMaterial(
                    title.trim(),
                    category != null ? category.trim() : "General",
                    contentText.trim(),
                    "Manual Input",
                    adminId != null ? adminId : 1
            );
        }

        response.sendRedirect("study-materials");
    }
}
