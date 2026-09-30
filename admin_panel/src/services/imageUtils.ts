import api from './api';

export const formatImageUrl = (url?: string | null): string => {
  if (!url || url.trim() === '') {
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
  }

  const trimmed = url.trim();

  // Handle relative uploads paths
  if (trimmed.startsWith('/uploads/') || trimmed.startsWith('uploads/')) {
    const cleanPath = trimmed.startsWith('/') ? trimmed : `/${trimmed}`;
    const baseUrl = api.defaults.baseURL || 'https://marinamart.onrender.com';
    return `${baseUrl}${cleanPath}`;
  }

  // Handle localhost / 127.0.0.1 / 10.0.2.2 URLs stored in DB when active server is Live
  if (trimmed.includes('localhost:5001') || trimmed.includes('127.0.0.1:5001') || trimmed.includes('10.0.2.2:5001')) {
    const baseUrl = api.defaults.baseURL || 'https://marinamart.onrender.com';
    if (!baseUrl.includes('localhost') && !baseUrl.includes('127.0.0.1')) {
      return trimmed
        .replace(/http:\/\/localhost:5001/g, baseUrl)
        .replace(/http:\/\/127\.0\.0\.1:5001/g, baseUrl)
        .replace(/http:\/\/10\.0\.2\.2:5001/g, baseUrl);
    }
  }

  return trimmed;
};
