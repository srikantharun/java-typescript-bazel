/**
 * API Client for User Service
 *
 * Demonstrates modern TypeScript patterns:
 * - Async/await for API calls
 * - Type-safe interfaces
 * - Error handling
 * - Builder pattern
 */

export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface CreateUserRequest {
  email: string;
  name: string;
}

export class UserApiClient {
  private readonly baseUrl: string;
  private readonly timeout: number;

  constructor(baseUrl: string, timeout: number = 5000) {
    this.baseUrl = baseUrl;
    this.timeout = timeout;
  }

  async createUser(request: CreateUserRequest): Promise<User> {
    const response = await this.post<User>('/users', request);
    if (!response.success || !response.data) {
      throw new Error(response.error || 'Failed to create user');
    }
    return response.data;
  }

  async getUser(userId: string): Promise<User> {
    const response = await this.get<User>(`/users/${userId}`);
    if (!response.success || !response.data) {
      throw new Error(response.error || 'User not found');
    }
    return response.data;
  }

  async getAllUsers(): Promise<Record<string, User>> {
    const response = await this.get<Record<string, User>>('/users');
    if (!response.success || !response.data) {
      throw new Error(response.error || 'Failed to fetch users');
    }
    return response.data;
  }

  async deleteUser(userId: string): Promise<void> {
    const response = await this.delete<string>(`/users/${userId}`);
    if (!response.success) {
      throw new Error(response.error || 'Failed to delete user');
    }
  }

  private async get<T>(path: string): Promise<ApiResponse<T>> {
    return this.request<T>('GET', path);
  }

  private async post<T>(path: string, body: unknown): Promise<ApiResponse<T>> {
    return this.request<T>('POST', path, body);
  }

  private async delete<T>(path: string): Promise<ApiResponse<T>> {
    return this.request<T>('DELETE', path);
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<ApiResponse<T>> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(`${this.baseUrl}${path}`, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        return {
          success: false,
          error: `HTTP ${response.status}: ${response.statusText}`,
        };
      }

      const data = await response.json();
      return data as ApiResponse<T>;
    } catch (error) {
      clearTimeout(timeoutId);
      if (error instanceof Error) {
        return {
          success: false,
          error: error.message,
        };
      }
      return {
        success: false,
        error: 'Unknown error occurred',
      };
    }
  }
}

/**
 * Builder for creating UserApiClient with fluent API
 */
export class UserApiClientBuilder {
  private baseUrl: string = 'http://localhost:8080';
  private timeout: number = 5000;

  withBaseUrl(baseUrl: string): this {
    this.baseUrl = baseUrl;
    return this;
  }

  withTimeout(timeout: number): this {
    this.timeout = timeout;
    return this;
  }

  build(): UserApiClient {
    return new UserApiClient(this.baseUrl, this.timeout);
  }
}
