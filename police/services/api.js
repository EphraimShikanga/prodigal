const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

/**
 * API service for communicating with the NestJS backend
 */
class ApiService {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  /**
   * Fetch all cases with optional status filter
   */
  async getCases(status = null) {
    const params = status ? `?status=${status}` : '';
    return this.request(`/cases${params}`);
  }

  /**
   * Fetch a single case by ID
   */
  async getCaseById(id) {
    return this.request(`/cases/${id}`);
  }

  /**
   * Get system metrics
   */
  async getMetrics() {
    return this.request('/cases/metrics');
  }

  /**
   * Update case status (verify/reject)
   */
  async updateCaseStatus(id, status) {
    return this.request(`/cases/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    });
  }

  /**
   * Create a new case
   */
  async createCase(caseData) {
    return this.request('/cases', {
      method: 'POST',
      body: JSON.stringify(caseData),
    });
  }
}

export const apiService = new ApiService(API_BASE_URL);
