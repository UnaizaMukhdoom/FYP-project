import React, { useState, useEffect } from 'react';
import { collection, getDocs, doc, getDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import './Analytics.css';

const Analytics = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    usersWithAnalysis: 0,
    usersWithCloset: 0,
    totalClosetItems: 0,
    totalAnalyses: 0,
    totalQuestionnaires: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    try {
      console.log('📊 Fetching analytics...');
      
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const users = usersSnapshot.docs;
      const totalUsers = users.filter(u => u.data().email || u.data().displayName).length;
      
      let usersWithAnalysis = 0;
      let usersWithCloset = 0;
      let totalClosetItems = 0;
      let totalAnalyses = 0;
      let totalQuestionnaires = 0;

      for (const userDoc of users) {
        try {
          // Check for analysis
          const analysisDoc = await getDoc(
            doc(db, 'users', userDoc.id, 'analysis', 'latest')
          );
          if (analysisDoc.exists()) {
            usersWithAnalysis++;
            totalAnalyses++;
          }

          // Check for closet items
          const closetSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'closet_items')
          );
          if (closetSnapshot.size > 0) {
            usersWithCloset++;
            totalClosetItems += closetSnapshot.size;
          }

          // Check for questionnaires
          // Count unique users who have questionnaires (not total documents)
          const onboardingSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'onboarding')
          );
          if (onboardingSnapshot.size > 0) {
            totalQuestionnaires++; // Count as 1 questionnaire per user
          }
        } catch (error) {
          console.log(`⚠️ Error checking user ${userDoc.id}:`, error.message);
        }
      }

      setStats({
        totalUsers,
        usersWithAnalysis,
        usersWithCloset,
        totalClosetItems,
        totalAnalyses,
        totalQuestionnaires,
      });
      
      console.log('✅ Analytics fetched successfully');
    } catch (error) {
      console.error('❌ Error fetching analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="page-loading">Loading analytics...</div>;
  }

  return (
    <div className="analytics-page">
      <div className="page-header">
        <h1>Analytics</h1>
        <p>View detailed analytics and insights</p>
        <button onClick={fetchAnalytics} className="refresh-btn">
          Refresh
        </button>
      </div>
      
      <div className="analytics-content">
        <div className="analytics-grid">
          <div className="stat-box">
            <h3>Total Users</h3>
            <p className="stat-value">{stats.totalUsers}</p>
            <p className="stat-label">Registered users</p>
          </div>
          
          <div className="stat-box">
            <h3>Users with Analysis</h3>
            <p className="stat-value">{stats.usersWithAnalysis}</p>
            <p className="stat-label">
              {stats.totalUsers > 0 
                ? `${Math.round((stats.usersWithAnalysis / stats.totalUsers) * 100)}% completion rate`
                : '0% completion rate'}
            </p>
          </div>
          
          <div className="stat-box">
            <h3>Users with Closet</h3>
            <p className="stat-value">{stats.usersWithCloset}</p>
            <p className="stat-label">
              {stats.totalUsers > 0 
                ? `${Math.round((stats.usersWithCloset / stats.totalUsers) * 100)}% have items`
                : '0% have items'}
            </p>
          </div>
          
          <div className="stat-box">
            <h3>Total Closet Items</h3>
            <p className="stat-value">{stats.totalClosetItems}</p>
            <p className="stat-label">Items in all closets</p>
          </div>
          
          <div className="stat-box">
            <h3>Total Analyses</h3>
            <p className="stat-value">{stats.totalAnalyses}</p>
            <p className="stat-label">Color analyses completed</p>
          </div>
          
          <div className="stat-box">
            <h3>Total Questionnaires</h3>
            <p className="stat-value">{stats.totalQuestionnaires}</p>
            <p className="stat-label">
              {stats.totalUsers > 0 
                ? `${Math.round((stats.totalQuestionnaires / stats.totalUsers) * 100)}% completion rate`
                : '0% completion rate'}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;

