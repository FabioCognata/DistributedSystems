<%@ page contentType="text/html;charset=UTF-8" %>
  <%@ page import="java.util.List" %>
    <%@ page import="com.unipi.dsmt.app.dtos.UserDepartmentDTO" %>
      <!DOCTYPE html>
      <html lang="en">

      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="css/department.css?v=1.5">
        <script src="js/searchbar.js?v=1.7" defer></script>
        <title>Department page</title>
      </head>

      <body style="margin: 0px;">
        <jsp:include page="/WEB-INF/jsp/components/nav_bar.jsp" />
        <div class="page">
          <div class="centerize">
            <div class="search">
              <input type="text" list="online-users" placeholder="Search" id="searchinput"
                oninput="handleChange(event)" />
              <img src="icons/search.png">
              <datalist id="online-users">
                <% for(UserDepartmentDTO user : (List<UserDepartmentDTO>)request.getAttribute("onlineUsers")){ %>
                  <option>
                    <%= user.getName() %>
                      <%= user.getSurname() %>
                        <%= user.getUsername() %>
                  </option>
                  <%}%>
              </datalist>
            </div>
          </div>
          <div class="centerize-board">
            <div class="users-board">
              <% for(UserDepartmentDTO user : (List<UserDepartmentDTO>)request.getAttribute("users")){ %>
                <% String className="flag" ; %>
                  <% if(user.isOnline_flag()){ className +=" connected" ; } %>
                    <div class="user-card">
                      <h1>
                        <%= user.getUsername() %>
                      </h1>
                      <h2>
                        <% String department_name=(String) request.getParameter("name"); %>
                        <%=department_name%>
                      </h2>
                      <h3>
                        <%= user.getName() %>
                          <%= user.getSurname() %>
                      </h3>
                      <div class="<%= className %>"></div>
                    </div>
                    <%}%>
            </div>
          </div>
          <jsp:include page="/WEB-INF/jsp/components/sidebar.jsp" />
        </div>
      </body>

      </html>