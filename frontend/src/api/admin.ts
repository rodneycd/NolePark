import apiClient from './index';
import type { AdminLotSummary, InfrastructureDetails, DashboardStats } from '@/types';

export default {
  async getInventory(): Promise<AdminLotSummary[]> {
    const { data } = await apiClient.get<AdminLotSummary[]>('/admin/inventory');
    return data;
  },

  async getInfrastructure(lotId: number): Promise<InfrastructureDetails> {
    const { data } = await apiClient.get<InfrastructureDetails>(`/admin/infrastructure/${lotId}`);
    return data;
  },

async deleteLot(lotId: number): Promise<{ message: string }> {
    const { data } = await apiClient.delete<{ message: string }>(`/admin/infrastructure/${lotId}`);
    return data;
  },

  async updateLevelPermit(lotId: number, levelId: number, permitType: string): Promise<{ message: string }> {
    const { data } = await apiClient.patch<{ message: string }>(
      `/admin/level/${lotId}/${levelId}`, 
      { permit_type: permitType }
    );
    return data;
  },
  // Inside AdminAPI object in src/api/admin.ts
  async getActiveSessions() {
    const response = await apiClient.get('/admin/active-sessions');
    return response.data;
  },

async getDashboardStats(): Promise<DashboardStats[]> {
  const { data } = await apiClient.get<DashboardStats[]>('/admin/dashboard-stats');
  return data;
},

async closeIndividualSession(sessionId: number) {
    const response = await apiClient.post(`/admin/sessions/close/${sessionId}`);
    return response.data;
  },
  async getInfrastructureSummary() {
    const response = await apiClient.get('/admin/infrastructure');
    return response.data;
  },
};