import apiClient from "./index";
import type { ParkingLot, LotSearchResult, LotSearchParams, LotLevelDetail, PredictionParams, PredictionResult } from "@/types";


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
  },
  
  async suggestLots(query: string): Promise<{ lot_id: number; lot_name: string }[]> {
    const { data } = await apiClient.get<{ lot_id: number; lot_name: string }[]>('/lots/suggest', {
      params: { q: query }
    });
    return data;
  },
  async predictLots(params: PredictionParams): Promise<PredictionResult[]> {
  const { data } = await apiClient.post<PredictionResult[]>('/lots/predict', params);
  return data;
  }
};