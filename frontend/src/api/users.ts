import apiClient from './index';
import type { UserProfile } from '@/types';

export default {
  async getUserProfile(id: number): Promise<UserProfile> {
    const { data } = await apiClient.get<UserProfile>(`/users/${id}`);
    return data;
  },

  async getAllUsers(): Promise<UserProfile[]> {
    const { data } = await apiClient.get<UserProfile[]>('/users');
    return data;
  },

  async getPermits(): Promise<{ permit_type: string }[]> {
    const { data } = await apiClient.get('/permits');
    return data;
},
  async updatePermit(userId: number, permitType: string): Promise<{ success: boolean; message: string }> {
    const { data } = await apiClient.put(`/users/${userId}/permit`, {
      permit_type: permitType
    });
    return data;
  }
};