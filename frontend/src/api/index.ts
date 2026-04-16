import axios from 'axios';

const apiClient = axios.create({
    baseURL: 'http://127.0.0.1:5001/api',
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 5000,
});

export default apiClient;