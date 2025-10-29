package com.example.userservice.test;

import com.example.userservice.model.User;
import com.example.userservice.repository.UserRepository;
import com.example.userservice.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Comprehensive unit tests for UserService.
 *
 * Demonstrates modern Java testing practices:
 * - JUnit 5
 * - Mockito for mocking
 * - AssertJ for fluent assertions
 */
@DisplayName("UserService Tests")
class UserServiceTest {

    @Mock
    private UserRepository repository;

    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        userService = new UserService(repository);
    }

    @Test
    @DisplayName("Should create user successfully")
    void testCreateUser() throws UserService.UserServiceException {
        // Given
        String email = "test@example.com";
        String name = "Test User";
        when(repository.findByEmail(email)).thenReturn(Optional.empty());
        when(repository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        User user = userService.createUser(email, name);

        // Then
        assertThat(user).isNotNull();
        assertThat(user.getEmail()).isEqualTo(email);
        assertThat(user.getName()).isEqualTo(name);
        assertThat(user.getId()).isNotNull();

        verify(repository).findByEmail(email);
        verify(repository).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception for empty email")
    void testCreateUserWithEmptyEmail() {
        // When/Then
        assertThatThrownBy(() -> userService.createUser("", "Test User"))
            .isInstanceOf(UserService.UserServiceException.class)
            .hasMessageContaining("Email cannot be empty");

        verify(repository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception for invalid email format")
    void testCreateUserWithInvalidEmail() {
        // When/Then
        assertThatThrownBy(() -> userService.createUser("invalidemail", "Test User"))
            .isInstanceOf(UserService.UserServiceException.class)
            .hasMessageContaining("Invalid email format");

        verify(repository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception for duplicate email")
    void testCreateUserWithDuplicateEmail() {
        // Given
        String email = "duplicate@example.com";
        User existingUser = User.create(email, "Existing User");
        when(repository.findByEmail(email)).thenReturn(Optional.of(existingUser));

        // When/Then
        assertThatThrownBy(() -> userService.createUser(email, "New User"))
            .isInstanceOf(UserService.UserServiceException.class)
            .hasMessageContaining("already exists");

        verify(repository).findByEmail(email);
        verify(repository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should get user by ID")
    void testGetUserById() {
        // Given
        UUID id = UUID.randomUUID();
        User user = new User(id, "test@example.com", "Test User", System.currentTimeMillis());
        when(repository.findById(id)).thenReturn(Optional.of(user));

        // When
        Optional<User> result = userService.getUserById(id);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get()).isEqualTo(user);
        verify(repository).findById(id);
    }

    @Test
    @DisplayName("Should return empty for non-existent user")
    void testGetNonExistentUser() {
        // Given
        UUID id = UUID.randomUUID();
        when(repository.findById(id)).thenReturn(Optional.empty());

        // When
        Optional<User> result = userService.getUserById(id);

        // Then
        assertThat(result).isEmpty();
        verify(repository).findById(id);
    }

    @Test
    @DisplayName("Should delete user successfully")
    void testDeleteUser() {
        // Given
        UUID id = UUID.randomUUID();
        when(repository.deleteById(id)).thenReturn(true);

        // When
        boolean deleted = userService.deleteUser(id);

        // Then
        assertThat(deleted).isTrue();
        verify(repository).deleteById(id);
    }

    @Test
    @DisplayName("Should return false when deleting non-existent user")
    void testDeleteNonExistentUser() {
        // Given
        UUID id = UUID.randomUUID();
        when(repository.deleteById(id)).thenReturn(false);

        // When
        boolean deleted = userService.deleteUser(id);

        // Then
        assertThat(deleted).isFalse();
        verify(repository).deleteById(id);
    }
}
