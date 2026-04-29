import apiClient from './index';
import type { AdminLotSummary, InfrastructureDetails, DashboardStats } from '@/types';

const adminHeader = () => ({
  headers: {
    'X-User-Id': localStorage.getItem('active_user_id')
  }
});

export default {
  async getInventory(): Promise<AdminLotSummary[]> {
    const { data } = await apiClient.get<AdminLotSummary[]>('/admin/inventory', adminHeader());
    return data;
  },

  async getInfrastructure(lotId: number): Promise<InfrastructureDetails> {
    const { data } = await apiClient.get<InfrastructureDetails>(`/admin/infrastructure/${lotId}`, adminHeader());
    return data;
  },

  async deleteLot(lotId: number): Promise<{ message: string }> {
    const { data } = await apiClient.delete<{ message: string }>(`/admin/infrastructure/${lotId}`, adminHeader());
    return data;
  },

  async updateLevelPermit(lotId: number, levelId: number, permitType: string): Promise<{ message: string }> {
    const { data } = await apiClient.patch<{ message: string }>(
      `/admin/level/${lotId}/${levelId}`, 
      { permit_type: permitType },
      adminHeader() 
    );
    return data;
  },

  async getActiveSessions() {
    const response = await apiClient.get('/admin/active-sessions', adminHeader());
    return response.data;
  },

  async getDashboardStats(): Promise<DashboardStats[]> {
    const { data } = await apiClient.get<DashboardStats[]>('/admin/dashboard-stats', adminHeader());
    return data;
  },

  async closeIndividualSession(sessionId: number) {
    const response = await apiClient.post(`/admin/sessions/close/${sessionId}`, {}, adminHeader());
    return response.data;
  },

  async getInfrastructureSummary() {
    const response = await apiClient.get('/admin/infrastructure', adminHeader());
    return response.data;
  },
};