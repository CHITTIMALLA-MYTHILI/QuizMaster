<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Direct legacy results to modern results servlet
    response.sendRedirect("results");
%>