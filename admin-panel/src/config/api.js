// API Configuration
// Update this to your Flask API URL
export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

// API endpoints
export const API_ENDPOINTS = {
  health: `${API_BASE_URL}/health`,
  analyze: `${API_BASE_URL}/analyze`,
  analyzeFaceShape: `${API_BASE_URL}/analyze-face-shape`,
  chatbot: `${API_BASE_URL}/chatbot/chat`,
  scrapeClothes: `${API_BASE_URL}/scrape-clothes`,
};

