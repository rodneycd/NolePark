import apiClient from "./index";
import type { ParkingLot, LotSearchResult, LotSearchParams, LotLevelDetail } from "@/types";

export default {
  async getLotsForUser(userId: number): Promise<ParkingLot[]> {
    const { data } = await apiClient.get<ParkingLot[]>(`/lots/occupancy/${userId}`);
    return data;
  },

  async searchLots(params: LotSearchParams): Promise<LotSearchResult[]> {
    const { data } = await apiClient.get<LotSearchResult[]>('/lots/search', { params });
    return data;
  },

  async getLotLevels(lotId: number): Promise<LotLevelDetail[]> {
    const { data } = await apiClient.get<LotLevelDetail[]>(`/lots/${lotId}/levels`);
    return data;
  }
};