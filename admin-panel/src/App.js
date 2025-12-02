import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Analytics from './pages/Analytics';
import ClothingManagement from './pages/ClothingManagement';
import JewelryManagement from './pages/JewelryManagement';
import QuestionnaireManagement from './pages/QuestionnaireManagement';
import ChatbotReview from './pages/ChatbotReview';
import ColorRecommendations from './pages/ColorRecommendations';
import Export from './pages/Export';
import ScraperConfig from './pages/ScraperConfig';
import Layout from './components/Layout';
import './App.css';

// Protected Route Component
const ProtectedRoute = ({ children }) => {
  const { currentUser, loading } = useAuth();

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh' 
      }}>
        <div>Loading...</div>
      </div>
    );
  }

  return currentUser ? children : <Navigate to="/login" />;
};

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Toaster position="top-right" />
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="users" element={<Users />} />
              <Route path="analytics" element={<Analytics />} />
              <Route path="clothing" element={<ClothingManagement />} />
              <Route path="jewelry" element={<JewelryManagement />} />
              <Route path="questionnaire" element={<QuestionnaireManagement />} />
              <Route path="chatbot" element={<ChatbotReview />} />
              <Route path="color-recommendations" element={<ColorRecommendations />} />
              <Route path="export" element={<Export />} />
              <Route path="scraper" element={<ScraperConfig />} />
            </Route>
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;

