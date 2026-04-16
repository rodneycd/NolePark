import apiClient from "./index";
import type { LoginCredentials, LoginResponse } from "@/types";

export default{
    async login(credentials: LoginCredentials): Promise<LoginResponse> {
        const { data } = await apiClient.post<LoginResponse>('/login', credentials);
        return data;
    }
}