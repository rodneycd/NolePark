import apiClient from "./index";
import type { 
    LoginCredentials, 
    LoginResponse,
    SignupCredentials,
    SignupResponse } from "@/types";

export default{
    async login(credentials: LoginCredentials): Promise<LoginResponse> {
        const { data } = await apiClient.post<LoginResponse>('/login', credentials);
        return data;
    },

    async signup(credentials: SignupCredentials): Promise<SignupResponse> {
        try {
            const { data } = await apiClient.post<SignupResponse>('/signup', credentials);
            return data;
        } catch (error: any) {
            const message = error.response?.data?.message || "Registration failed";
            throw new Error(message);
        } 
    }

}