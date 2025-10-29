package com.example.userservice.model;

import java.util.Objects;
import java.util.UUID;

/**
 * User domain model.
 *
 * Demonstrates clean domain modeling in an enterprise microservice.
 */
public class User {
    private final UUID id;
    private final String email;
    private final String name;
    private final long createdAt;

    public User(UUID id, String email, String name, long createdAt) {
        this.id = Objects.requireNonNull(id, "id cannot be null");
        this.email = Objects.requireNonNull(email, "email cannot be null");
        this.name = Objects.requireNonNull(name, "name cannot be null");
        this.createdAt = createdAt;
    }

    public static User create(String email, String name) {
        return new User(
            UUID.randomUUID(),
            email,
            name,
            System.currentTimeMillis()
        );
    }

    public UUID getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", email='" + email + '\'' +
                ", name='" + name + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
