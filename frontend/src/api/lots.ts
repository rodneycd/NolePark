import apiClient from "./index";
import type { ParkingLot } from "@/types";

export default {
  async getLotsForUser(userId: number): Promise<ParkingLot[]> {
    const { data } = await apiClient.get<ParkingLot[]>(`/lots/occupancy/${userId}`);
    return data;
  }
};