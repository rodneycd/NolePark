import apiClient from "./index";
import type { ParkingSession, StartSessionPayload, Vehicle } from "@/types";

export default {
  async getActiveSession(userId: number): Promise<ParkingSession | null> {
    try {
      const { data } = await apiClient.get<ParkingSession>(`/sessions/${userId}/active`);
      return data;
    } catch {
      return null;
    }
  },

  async startSession(userId: number, payload: StartSessionPayload): Promise<void> {
    await apiClient.post(`/sessions/${userId}/start`, payload);
  },

  async endSession(userId: number, sessionId: number): Promise<void> {
    await apiClient.post(`/sessions/${userId}/end/${sessionId}`);
  },

  async getUserVehicles(userId: number): Promise<Vehicle[]> {
    const { data } = await apiClient.get<Vehicle[]>(`/users/${userId}/vehicles`);
    return data;
  }
};