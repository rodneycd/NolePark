export interface LoginCredentials {
    email: string;
    password: string;
}

export interface LoginResponse{
    success: boolean;
    user_id: number;
    message?: string;
}
export interface SignupCredentials {
  name: string;
  email: string;
  password: string;
  fsuid: string;
}

export interface SignupResponse {
  success: boolean;
  user_id?: number;
  message: string;
}

export interface UserProfile {
  user_id: number;
  name: string;
  email: string;
  user_role: 'admin' | 'student' | 'user';
  fsuid?: string | null;
  permit_type?: string | null;
}

export interface ParkingLot {
  lot_id: number;
  lot_name: string;
  lot_type: 'garage' | 'surface';
  user_available: number;
  user_total_capacity: number;
  user_pct_full: number;
}

export interface Vehicle {
  license_plate: string;
  make: string;
  model: string;
  color: string;
  year: number;
  owner_id?: number;
}

export interface LotSearchResult extends ParkingLot {
  address?: string;
  handicap_spots: number;
  motorcycle_spots: number;
  level_count: number;
  allowed_permit_types: string[];
}

export interface LotSearchParams {
  name?: string;
  lot_type?: string;
  spot_type?: string;
  occupancy_percent?: number;
  available?: number;
}
export interface LotLevelDetail {
  level_id: number;
  level_number: number;
  allowed_permit_type: string;
  available: number;
  total_spots: number;
  avail_handicap: number;
  avail_motorcycle: number;
  pct_full: string;
}
export interface ParkingSession {
  session_id: number;
  lot_name: string;
  spot_number: string;
  start_time: string;
  vehicle_make: string;
  vehicle_model: string;
  vehicle_plate: string;
}

export interface StartSessionPayload {
  license_plate: string;
  lot_id: number;
  spot_number: string;
}

export interface AdminLotSummary extends ParkingLot {
  levels: number;
  total_spots: number;
  occupied: number;
}

export interface AdminLevelConfig {
  level_id: number;
  lot_id: number;
  level_number: number;
  allowed_permit_type: string;
  lot_name?: string; // Joined for display convenience
}

export interface SpotBreakdown {
  spot_type: 'standard' | 'handicap' | 'motorcycle';
  status: 'available' | 'occupied';
  count: number;
}

export interface InfrastructureDetails {
  levels: AdminLevelConfig[];
  spots: SpotBreakdown[];
}

export interface DashboardStats {
  label: string;
  value: number | string;
  trend?: string;
  icon?: string;
}

export interface AdminActiveSession extends ParkingSession {
  owner_name: string;
  fsuid: string;
  permit_type: string;
  level_number: number;
  lot_id: number;
  duration: string;
  start_time_fmt: string;
  color: string;

export interface PredictionParams {
  permit_type: string;
  day_of_week: number;
  arrival_time: string;
}

export interface PredictionResult {
  lot_id: number;
  lot_name: string;
  lot_type: 'garage' | 'surface';
  level_id: number;
  level_number: number;
  total_spots: number;
  historical_occupied: number;
  current_occupied: number;
  predicted_occupied: number;
  predicted_available: number;
  predicted_percent_full: number;
  congestion_label: string;
  recommendation_rank: number;
}