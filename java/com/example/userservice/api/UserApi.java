package com.example.userservice.api;

import com.example.userservice.model.User;
import com.example.userservice.service.UserService;
import com.google.gson.Gson;
import javax.inject.Inject;
import javax.inject.Singleton;
import java.util.Map;
import java.util.UUID;

/**
 * REST API layer for user operations.
 *
 * Demonstrates API design and JSON serialization.
 */
@Singleton
public class UserApi {
    private final UserService userService;
    private final Gson gson;

    @Inject
    public UserApi(UserService userService) {
        this.userService = userService;
        this.gson = new Gson();
    }

    public String createUser(String requestJson) {
        CreateUserRequest request = gson.fromJson(requestJson, CreateUserRequest.class);

        try {
            User user = userService.createUser(request.email, request.name);
            UserResponse response = UserResponse.fromUser(user);
            return gson.toJson(new ApiResponse<>(true, response, null));
        } catch (UserService.UserServiceException e) {
            return gson.toJson(new ApiResponse<>(false, null, e.getMessage()));
        }
    }

    public String getUser(String userId) {
        try {
            UUID id = UUID.fromString(userId);
            return userService.getUserById(id)
                .map(user -> gson.toJson(new ApiResponse<>(true, UserResponse.fromUser(user), null)))
                .orElse(gson.toJson(new ApiResponse<>(false, null, "User not found")));
        } catch (IllegalArgumentException e) {
            return gson.toJson(new ApiResponse<>(false, null, "Invalid user ID"));
        }
    }

    public String getAllUsers() {
        Map<UUID, User> users = userService.getAllUsers();
        Map<UUID, UserResponse> responses = users.entrySet().stream()
            .collect(java.util.stream.Collectors.toMap(
                Map.Entry::getKey,
                e -> UserResponse.fromUser(e.getValue())
            ));
        return gson.toJson(new ApiResponse<>(true, responses, null));
    }

    public String deleteUser(String userId) {
        try {
            UUID id = UUID.fromString(userId);
            boolean deleted = userService.deleteUser(id);
            if (deleted) {
                return gson.toJson(new ApiResponse<>(true, "User deleted", null));
            } else {
                return gson.toJson(new ApiResponse<>(false, null, "User not found"));
            }
        } catch (IllegalArgumentException e) {
            return gson.toJson(new ApiResponse<>(false, null, "Invalid user ID"));
        }
    }

    private static class CreateUserRequest {
        String email;
        String name;
    }

    private static class UserResponse {
        String id;
        String email;
        String name;
        long createdAt;

        static UserResponse fromUser(User user) {
            UserResponse response = new UserResponse();
            response.id = user.getId().toString();
            response.email = user.getEmail();
            response.name = user.getName();
            response.createdAt = user.getCreatedAt();
            return response;
        }
    }

    private static class ApiResponse<T> {
        boolean success;
        T data;
        String error;

        ApiResponse(boolean success, T data, String error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
}
