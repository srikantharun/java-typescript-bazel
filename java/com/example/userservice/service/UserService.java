package com.example.userservice.service;

import com.example.userservice.model.User;
import com.example.userservice.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.inject.Inject;
import javax.inject.Singleton;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * User service containing business logic.
 *
 * Demonstrates clean architecture with dependency injection,
 * logging, and business rule validation.
 */
@Singleton
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    private final UserRepository repository;

    @Inject
    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public User createUser(String email, String name) throws UserServiceException {
        logger.info("Creating user with email: {}", email);

        // Validate input
        if (email == null || email.trim().isEmpty()) {
            throw new UserServiceException("Email cannot be empty");
        }
        if (!email.contains("@")) {
            throw new UserServiceException("Invalid email format");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new UserServiceException("Name cannot be empty");
        }

        // Check for duplicate
        Optional<User> existing = repository.findByEmail(email);
        if (existing.isPresent()) {
            throw new UserServiceException("User with email " + email + " already exists");
        }

        // Create and save user
        User user = User.create(email, name);
        User saved = repository.save(user);

        logger.info("User created successfully: {}", saved.getId());
        return saved;
    }

    public Optional<User> getUserById(UUID id) {
        logger.debug("Fetching user by id: {}", id);
        return repository.findById(id);
    }

    public Optional<User> getUserByEmail(String email) {
        logger.debug("Fetching user by email: {}", email);
        return repository.findByEmail(email);
    }

    public Map<UUID, User> getAllUsers() {
        logger.debug("Fetching all users");
        return repository.findAll();
    }

    public boolean deleteUser(UUID id) {
        logger.info("Deleting user: {}", id);
        boolean deleted = repository.deleteById(id);
        if (deleted) {
            logger.info("User deleted successfully: {}", id);
        } else {
            logger.warn("User not found for deletion: {}", id);
        }
        return deleted;
    }

    public static class UserServiceException extends Exception {
        public UserServiceException(String message) {
            super(message);
        }
    }
}
