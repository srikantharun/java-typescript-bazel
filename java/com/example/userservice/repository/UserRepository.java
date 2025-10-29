package com.example.userservice.repository;

import com.example.userservice.model.User;
import com.google.common.collect.ImmutableMap;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import javax.inject.Singleton;

/**
 * In-memory user repository implementation.
 *
 * Demonstrates dependency injection and repository pattern.
 */
@Singleton
public class UserRepository {
    private final ConcurrentHashMap<UUID, User> users = new ConcurrentHashMap<>();

    public User save(User user) {
        users.put(user.getId(), user);
        return user;
    }

    public Optional<User> findById(UUID id) {
        return Optional.ofNullable(users.get(id));
    }

    public Optional<User> findByEmail(String email) {
        return users.values().stream()
            .filter(user -> user.getEmail().equals(email))
            .findFirst();
    }

    public ImmutableMap<UUID, User> findAll() {
        return ImmutableMap.copyOf(users);
    }

    public boolean deleteById(UUID id) {
        return users.remove(id) != null;
    }

    public long count() {
        return users.size();
    }

    public void clear() {
        users.clear();
    }
}
