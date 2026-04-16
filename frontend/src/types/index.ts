export interface LoginCredentials {
    email: string;
    password: string;
}

export interface LoginResponse{
    success: boolean;
    user_id: number;
    message?: string;
}

export interface UserProfile {
  user_id: number;
  name: string;
  email: string;
  user_role: 'admin' | 'student' | 'user';
  fsuid?: string | null;
  permit_type?: string | null;
}