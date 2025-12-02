import React, { useState, useEffect } from 'react';
import { collection, getDocs, query, where, onSnapshot } from 'firebase/firestore';
import { db } from '../config/firebase';
import {
  Users,
  FileText,
  MessageSquare,
  TrendingUp,
  Shirt,
  Gem,
  RefreshCw,
} from 'lucide-react';
import './Dashboard.css';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalAnalyses: 0,
    totalChats: 0,
    totalClothing: 0,
    totalJewelry: 0,
    totalQuestionnaires: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
    
    // Set up real-time listener for users collection
    // This will auto-update when new users are added
    const unsubscribe = onSnapshot(
      collection(db, 'users'),
      (snapshot) => {
        console.log('🔄 Users collection updated, refreshing stats...');
        fetchStats();
      },
      (error) => {
        console.error('Error in real-time listener:', error);
      }
    );
    
    // Cleanup listener on unmount
    return () => unsubscribe();
  }, []);

  const fetchStats = async () => {
    try {
      console.log('📊 Fetching dashboard statistics...');
      
      // Fetch users count (from top-level users collection)
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const totalUsers = usersSnapshot.size;
      console.log(`👥 Found ${totalUsers} users in Firestore`);

      const users = usersSnapshot.docs;
      
      // If no users in Firestore, check if there are any subcollections
      // (users might have data but not be synced to top-level collection)
      if (totalUsers === 0) {
        console.warn('⚠️ No users found in top-level users collection');
        console.log('💡 Tip: Users need to sign in/up in Flutter app to sync to admin panel');
      }

      // Fetch analyses count from user subcollections
      // Flutter app saves to: users/{uid}/analysis/latest
      let totalAnalyses = 0;
      for (const userDoc of users) {
        try {
          const analysisDoc = await getDocs(
            collection(db, 'users', userDoc.id, 'analysis')
          );
          if (analysisDoc.size > 0) {
            totalAnalyses++;
            console.log(`✅ Found analysis for user: ${userDoc.id}`);
          }
        } catch (e) {
          console.log(`⚠️ Error fetching analysis for user ${userDoc.id}:`, e.message);
        }
      }
      console.log(`📊 Total analyses: ${totalAnalyses}`);

      // Fetch chats count (from chatbot interactions - if exists)
      let totalChats = 0;
      try {
        const chatsSnapshot = await getDocs(collection(db, 'chatbot_interactions'));
        totalChats = chatsSnapshot.size;
        console.log(`💬 Total chatbot interactions: ${totalChats}`);
      } catch (e) {
        // Collection might not exist yet
        console.log('ℹ️ Chatbot interactions collection not found (this is normal if no chats yet)');
      }

      // Fetch clothing items count from user subcollections
      // Flutter app saves to: users/{uid}/closet_items
      let totalClothing = 0;
      for (const userDoc of users) {
        try {
          const closetSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'closet_items')
          );
          const count = closetSnapshot.size;
          totalClothing += count;
          if (count > 0) {
            console.log(`👔 Found ${count} closet items for user: ${userDoc.id}`);
          }
        } catch (e) {
          console.log(`⚠️ Error fetching closet items for user ${userDoc.id}:`, e.message);
        }
      }
      console.log(`👔 Total clothing items: ${totalClothing}`);

      // Fetch jewelry recommendations (from face shape analyses)
      // Check if face_shape data exists in analysis subcollections
      let totalJewelry = 0;
      for (const userDoc of users) {
        try {
          const analysisSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'analysis')
          );
          analysisSnapshot.docs.forEach((doc) => {
            const data = doc.data();
            // Check multiple possible paths for face_shape data
            if (data.analysis?.face_shape || data.face_shape || data.faceShape) {
              totalJewelry++;
              console.log(`💎 Found jewelry recommendation for user: ${userDoc.id}`);
            }
          });
        } catch (e) {
          console.log(`⚠️ Error fetching jewelry data for user ${userDoc.id}:`, e.message);
        }
      }
      console.log(`💎 Total jewelry recommendations: ${totalJewelry}`);

      // Fetch questionnaires count from user subcollections
      // Flutter app saves to: users/{uid}/onboarding
      // Count unique users who have completed questionnaire (not total documents)
      let totalQuestionnaires = 0;
      for (const userDoc of users) {
        try {
          const onboardingSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'onboarding')
          );
          // Count as 1 questionnaire per user (not per document)
          // This way: 2 users = 2 questionnaires, not 12 documents
          if (onboardingSnapshot.size > 0) {
            totalQuestionnaires++;
            console.log(`📝 User ${userDoc.id} has ${onboardingSnapshot.size} onboarding document(s) - counted as 1 questionnaire`);
          }
        } catch (e) {
          console.log(`⚠️ Error fetching onboarding for user ${userDoc.id}:`, e.message);
        }
      }
      console.log(`📝 Total questionnaires (unique users): ${totalQuestionnaires}`);

      console.log('✅ Dashboard stats fetched successfully:', {
        totalUsers,
        totalAnalyses,
        totalChats,
        totalClothing,
        totalJewelry,
        totalQuestionnaires,
      });

      setStats({
        totalUsers,
        totalAnalyses,
        totalChats,
        totalClothing,
        totalJewelry,
        totalQuestionnaires,
      });
    } catch (error) {
      console.error('❌ Error fetching stats:', error);
      console.error('Error details:', error.message, error.stack);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    {
      title: 'Total Users',
      value: stats.totalUsers,
      icon: Users,
      color: '#3498db',
    },
    {
      title: 'Color Analyses',
      value: stats.totalAnalyses,
      icon: FileText,
      color: '#9b59b6',
    },
    {
      title: 'Chatbot Interactions',
      value: stats.totalChats,
      icon: MessageSquare,
      color: '#e74c3c',
    },
    {
      title: 'Clothing Items',
      value: stats.totalClothing,
      icon: Shirt,
      color: '#f39c12',
    },
    {
      title: 'Jewelry Recommendations',
      value: stats.totalJewelry,
      icon: Gem,
      color: '#1abc9c',
    },
    {
      title: 'Questionnaires',
      value: stats.totalQuestionnaires,
      icon: TrendingUp,
      color: '#34495e',
    },
  ];

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div>Loading dashboard...</div>
      </div>
    );
  }

  const allZero = Object.values(stats).every(val => val === 0);

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h1>Dashboard</h1>
            <p>Welcome to VOGUE AI Admin Panel</p>
          </div>
          <button
            onClick={fetchStats}
            disabled={loading}
            style={{
              padding: '8px 16px',
              backgroundColor: '#3498db',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: loading ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              fontSize: '14px',
            }}
          >
            <RefreshCw size={16} style={{ animation: loading ? 'spin 1s linear infinite' : 'none' }} />
            Refresh
          </button>
        </div>
      </div>

      {allZero && (
        <div style={{
          backgroundColor: '#fff3cd',
          border: '1px solid #ffc107',
          borderRadius: '8px',
          padding: '16px',
          marginBottom: '24px',
        }}>
          <h3 style={{ margin: '0 0 8px 0', color: '#856404' }}>⚠️ No Data Found</h3>
          <p style={{ margin: '0', color: '#856404', fontSize: '14px' }}>
            All statistics are showing 0. This could mean:
          </p>
          <ul style={{ margin: '8px 0 0 0', paddingLeft: '20px', color: '#856404', fontSize: '14px' }}>
            <li>No users have signed up/signed in yet in the Flutter app</li>
            <li>Users exist in Firebase Auth but haven't been synced to Firestore</li>
            <li>No data has been created yet (analyses, closet items, etc.)</li>
          </ul>
          <p style={{ margin: '12px 0 0 0', color: '#856404', fontSize: '14px', fontWeight: 'bold' }}>
            💡 Solution: Have users sign in/up in the Flutter app to sync their data to the admin panel.
          </p>
        </div>
      )}

      <div className="stats-grid">
        {statCards.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="stat-card">
              <div className="stat-icon" style={{ backgroundColor: `${stat.color}20` }}>
                <Icon size={24} color={stat.color} />
              </div>
              <div className="stat-content">
                <div className="stat-value">{stat.value}</div>
                <div className="stat-title">{stat.title}</div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default Dashboard;

