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