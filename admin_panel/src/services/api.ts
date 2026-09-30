import axios from 'axios';

// ── SERVER ENVIRONMENT TOGGLE ──────────────────────────────────────────────
// Set USE_LIVE_SERVER = true to connect to Live Production Server.
// Set USE_LIVE_SERVER = false to connect to Localhost Server.
const USE_LIVE_SERVER = true;

const LIVE_SERVER_URL = 'https://marinamart.onrender.com';
const LOCAL_SERVER_URL = 'http://localhost:5001';

const API_BASE_URL = import.meta.env.VITE_API_URL || (USE_LIVE_SERVER ? LIVE_SERVER_URL : LOCAL_SERVER_URL);

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add a request interceptor to attach the JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor to handle 401s
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Clear local storage and redirect to login if unauthorized
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
