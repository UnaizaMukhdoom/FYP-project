import React, { useState } from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  LayoutDashboard,
  Users,
  BarChart3,
  Shirt,
  Gem,
  FileText,
  MessageSquare,
  Palette,
  Download,
  Settings,
  LogOut,
  Menu,
  X,
} from 'lucide-react';
import './Layout.css';

const Layout = () => {
  const { currentUser, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const menuItems = [
    { path: '/', icon: LayoutDashboard, label: 'Dashboard' },
    { path: '/users', icon: Users, label: 'Users' },
    { path: '/analytics', icon: BarChart3, label: 'Analytics' },
    { path: '/clothing', icon: Shirt, label: 'Clothing' },
    { path: '/jewelry', icon: Gem, label: 'Jewelry' },
    { path: '/questionnaire', icon: FileText, label: 'Questionnaire' },
    { path: '/chatbot', icon: MessageSquare, label: 'Chatbot Review' },
    { path: '/color-recommendations', icon: Palette, label: 'Color Recommendations' },
    { path: '/export', icon: Download, label: 'Export Data' },
    { path: '/scraper', icon: Settings, label: 'Scraper Config' },
  ];

  return (
    <div className="layout-container">
      {/* Sidebar */}
      <aside className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          <h2>VOGUE AI</h2>
          <button
            className="sidebar-toggle"
            onClick={() => setSidebarOpen(!sidebarOpen)}
          >
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        <nav className="sidebar-nav">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-item ${isActive ? 'active' : ''}`}
              >
                <Icon size={20} />
                {sidebarOpen && <span>{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <div className="user-info">
            {sidebarOpen && (
              <>
                <div className="user-email">{currentUser?.email}</div>
                <div className="user-role">Admin</div>
              </>
            )}
          </div>
          <button className="logout-btn" onClick={handleLogout}>
            <LogOut size={20} />
            {sidebarOpen && <span>Logout</span>}
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;

