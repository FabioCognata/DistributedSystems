package com.unipi.dsmt.app.daos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;

import com.unipi.dsmt.app.dtos.UserDepartmentDTO;
import com.unipi.dsmt.app.dtos.UserProfileDTO;
import com.unipi.dsmt.app.entities.User;

public class UserDAO {
  private Connection userConnection = null;

  public UserDAO(Connection db) {
    userConnection = db;
  }

  public boolean exists(String username) throws SQLException {
    String sqlString = "SELECT username FROM user WHERE username=?";
    PreparedStatement statement = userConnection.prepareStatement(sqlString);
    statement.setString(1, username);
    ResultSet set = statement.executeQuery();
    return set.next();
  }

  public boolean valid(String username, String password) throws SQLException {
    String sqlString = "SELECT password FROM user WHERE username=?";
    PreparedStatement statement = userConnection.prepareStatement(sqlString);
    statement.setString(1, username);
    ResultSet set = statement.executeQuery();
    set.next();
    String storedPassword = set.getString(1);
    // encrypt password and return storedPassword.equals(encryptedPassword)
    return storedPassword.equals(password);
  }

  public String save(User userInfo) throws SQLException {
    try {
      String sqlString = "INSERT INTO user(username, password, name, surname, department, onlineFlag, creationTime) VALUES (?, ?, ?, ?, ?, ?, ?)";
      PreparedStatement statement = userConnection.prepareStatement(sqlString);
      statement.setString(1, userInfo.getUsername());
      statement.setString(2, userInfo.getPassword());
      statement.setString(3, userInfo.getName());
      statement.setString(4, userInfo.getSurname());
      statement.setString(5, userInfo.getDepartment().toString());
      statement.setBoolean(6, userInfo.getOnline_flag());
      statement.setDate(7, userInfo.getCreationTime());
      int changedCount = statement.executeUpdate();
      return changedCount == 0 ? "User already exists" : "";
    } catch (SQLIntegrityConstraintViolationException e) {
      return "User already exists";
    }
  }

  public Boolean setOnlineFlag(Boolean flag, String username) throws SQLException {
    String sqlString = "UPDATE user SET onlineFlag = ? WHERE username = ?";
    PreparedStatement statement = userConnection.prepareStatement(sqlString);
    statement.setBoolean(1, flag);
    statement.setString(2, username);
    int changedCount = statement.executeUpdate();
    return changedCount == 1 ? true : false;
  }

  public ArrayList<UserDepartmentDTO> getUsersFromDepartment(String department) throws SQLException {
    ArrayList<UserDepartmentDTO> result = new ArrayList<>();
    String sqlString = "SELECT username, name, surname, onlineFlag FROM user WHERE department=?";
    PreparedStatement statement = userConnection.prepareStatement(sqlString);
    String dep_name;
    if (department.equals("Information Technologies"))
      dep_name = "IT";
    else if (department.equals("Human Resources"))
      dep_name = "HR";
    else
      dep_name = department;
    statement.setString(1, dep_name);
    ResultSet set = statement.executeQuery();
    while (set.next()) {
      UserDepartmentDTO user = new UserDepartmentDTO(set.getString("username"), set.getString("name"),
          set.getString("surname"), set.getBoolean("onlineFlag"));
      result.add(user);
    }
    return result;
  }

  public UserProfileDTO getUserFromUsername(String username) throws SQLException {
    String sqlString = "SELECT name, surname, onlineFlag, department FROM user WHERE username=?";
    PreparedStatement statement = userConnection.prepareStatement(sqlString);
    statement.setString(1, username);
    ResultSet set = statement.executeQuery();
    set.next();
    UserProfileDTO user = new UserProfileDTO(username, set.getString("name"), set.getString("surname"),
        set.getBoolean("onlineFlag"), set.getString("department"));
    return user;

  }

}
