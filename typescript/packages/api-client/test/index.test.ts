/**
 * Tests for UserApiClient
 *
 * Demonstrates modern TypeScript testing with Jest
 */

import { UserApiClient, UserApiClientBuilder, CreateUserRequest, User } from '../src/index';

// Mock fetch globally
global.fetch = jest.fn();

describe('UserApiClient', () => {
  let client: UserApiClient;
  const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

  beforeEach(() => {
    client = new UserApiClientBuilder()
      .withBaseUrl('http://test-api:8080')
      .withTimeout(1000)
      .build();
    mockFetch.mockClear();
  });

  describe('createUser', () => {
    it('should create user successfully', async () => {
      const request: CreateUserRequest = {
        email: 'test@example.com',
        name: 'Test User',
      };

      const mockUser: User = {
        id: '123e4567-e89b-12d3-a456-426614174000',
        email: request.email,
        name: request.name,
        createdAt: Date.now(),
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: true,
          data: mockUser,
        }),
      } as Response);

      const result = await client.createUser(request);

      expect(result).toEqual(mockUser);
      expect(mockFetch).toHaveBeenCalledWith(
        'http://test-api:8080/users',
        expect.objectContaining({
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(request),
        })
      );
    });

    it('should throw error when creation fails', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: false,
          error: 'Email already exists',
        }),
      } as Response);

      const request: CreateUserRequest = {
        email: 'duplicate@example.com',
        name: 'Test User',
      };

      await expect(client.createUser(request)).rejects.toThrow('Email already exists');
    });
  });

  describe('getUser', () => {
    it('should fetch user by ID', async () => {
      const userId = '123e4567-e89b-12d3-a456-426614174000';
      const mockUser: User = {
        id: userId,
        email: 'test@example.com',
        name: 'Test User',
        createdAt: Date.now(),
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: true,
          data: mockUser,
        }),
      } as Response);

      const result = await client.getUser(userId);

      expect(result).toEqual(mockUser);
      expect(mockFetch).toHaveBeenCalledWith(
        `http://test-api:8080/users/${userId}`,
        expect.any(Object)
      );
    });

    it('should throw error when user not found', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: false,
          error: 'User not found',
        }),
      } as Response);

      await expect(client.getUser('nonexistent-id')).rejects.toThrow('User not found');
    });
  });

  describe('getAllUsers', () => {
    it('should fetch all users', async () => {
      const mockUsers = {
        'id1': { id: 'id1', email: 'user1@example.com', name: 'User 1', createdAt: Date.now() },
        'id2': { id: 'id2', email: 'user2@example.com', name: 'User 2', createdAt: Date.now() },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: true,
          data: mockUsers,
        }),
      } as Response);

      const result = await client.getAllUsers();

      expect(result).toEqual(mockUsers);
      expect(Object.keys(result)).toHaveLength(2);
    });
  });

  describe('deleteUser', () => {
    it('should delete user successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: true,
          data: 'User deleted',
        }),
      } as Response);

      await expect(client.deleteUser('test-id')).resolves.not.toThrow();
    });

    it('should throw error when deletion fails', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: false,
          error: 'User not found',
        }),
      } as Response);

      await expect(client.deleteUser('nonexistent-id')).rejects.toThrow('User not found');
    });
  });

  describe('error handling', () => {
    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'));

      await expect(client.getUser('test-id')).rejects.toThrow('Network error');
    });

    it('should handle HTTP errors', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
      } as Response);

      await expect(client.getUser('test-id')).rejects.toThrow('HTTP 500');
    });
  });
});

describe('UserApiClientBuilder', () => {
  it('should build client with custom configuration', () => {
    const client = new UserApiClientBuilder()
      .withBaseUrl('http://custom-url:9090')
      .withTimeout(10000)
      .build();

    expect(client).toBeInstanceOf(UserApiClient);
  });

  it('should use default values', () => {
    const client = new UserApiClientBuilder().build();

    expect(client).toBeInstanceOf(UserApiClient);
  });
});
