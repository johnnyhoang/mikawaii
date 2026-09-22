export const API_BASE_URL = 
  import.meta.env.VITE_API_URL || 
  import.meta.env.VITE_BACKEND_URL || 
  (import.meta.env.PROD ? '' : 'http://localhost:5003');

export const backendUrl = API_BASE_URL;
