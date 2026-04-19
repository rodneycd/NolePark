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