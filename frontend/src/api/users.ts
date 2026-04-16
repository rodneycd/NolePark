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
  }
};