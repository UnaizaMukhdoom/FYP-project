import React, { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import './QuestionnaireManagement.css';

const QuestionnaireManagement = () => {
  const [questionnaires, setQuestionnaires] = useState([]);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState('latest'); // 'latest' or 'all'

  useEffect(() => {
    fetchQuestionnaires();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchQuestionnaires = async () => {
    try {
      console.log('📝 Fetching questionnaires...');
      
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const userQuestionnaires = [];

      // For each user, get their onboarding/questionnaire data
      for (const userDoc of usersSnapshot.docs) {
        try {
          const userData = userDoc.data();
          const onboardingSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'onboarding')
          );
          
          if (onboardingSnapshot.docs.length > 0) {
            // Sort by createdAt to get latest first
            const sortedDocs = onboardingSnapshot.docs.sort((a, b) => {
              const aTime = a.data().createdAt?.seconds || 0;
              const bTime = b.data().createdAt?.seconds || 0;
              return bTime - aTime; // Latest first
            });

            // Get name from questionnaire (first question)
            const latestQuestionnaire = sortedDocs[0].data();
            const userName = latestQuestionnaire.name || userData.displayName || 'No name';

            if (viewMode === 'latest') {
              // Show only latest questionnaire per user
              userQuestionnaires.push({
                userId: userDoc.id,
                userEmail: userData.email || 'Unknown',
                userName: userName,
                questionnaire: latestQuestionnaire,
                totalEntries: sortedDocs.length,
                latestDate: latestQuestionnaire.createdAt,
              });
            } else {
              // Show all questionnaires
              sortedDocs.forEach((qDoc) => {
                userQuestionnaires.push({
                  id: qDoc.id,
                  userId: userDoc.id,
                  userEmail: userData.email || 'Unknown',
                  userName: userName,
                  questionnaire: qDoc.data(),
                  createdAt: qDoc.data().createdAt,
                });
              });
            }
          }
        } catch (error) {
          console.log(`⚠️ Error fetching questionnaire for user ${userDoc.id}:`, error.message);
        }
      }

      // Sort by latest date
      userQuestionnaires.sort((a, b) => {
        const aTime = a.latestDate?.seconds || a.createdAt?.seconds || 0;
        const bTime = b.latestDate?.seconds || b.createdAt?.seconds || 0;
        return bTime - aTime;
      });

      console.log(`✅ Found ${userQuestionnaires.length} questionnaire entries`);
      setQuestionnaires(userQuestionnaires);
    } catch (error) {
      console.error('❌ Error fetching questionnaires:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="page-loading">Loading questionnaires...</div>;
  }

  const formatQuestionnaireData = (data) => {
    const formatted = [];
    
    // Name (from first question)
    if (data.name) {
      formatted.push({ label: 'Name', value: data.name, important: true });
    }
    
    // Body measurements
    if (data.heightCm) {
      const height = data.useFt 
        ? `${(data.heightCm / 30.48).toFixed(1)} ft`
        : `${data.heightCm} cm`;
      formatted.push({ label: 'Height', value: height });
    }
    
    if (data.weightKg) {
      const weight = data.useLb
        ? `${(data.weightKg * 2.20462).toFixed(1)} lbs`
        : `${data.weightKg} kg`;
      formatted.push({ label: 'Weight', value: weight });
    }
    
    // Body type and size
    if (data.bodyType) {
      formatted.push({ label: 'Body Type', value: data.bodyType, important: true });
    }
    
    if (data.sizeRange) {
      formatted.push({ label: 'Size Range', value: data.sizeRange, important: true });
    }
    
    // Style preferences
    if (data.fitPrefs && Array.isArray(data.fitPrefs) && data.fitPrefs.length > 0) {
      formatted.push({ label: 'Fit Preferences', value: data.fitPrefs.join(', '), important: true });
    }
    
    if (data.styleGoal) {
      formatted.push({ label: 'Style Goal', value: data.styleGoal, important: true });
    }
    
    return formatted;
  };

  return (
    <div className="questionnaire-page">
      <div className="page-header">
        <h1>Questionnaire Management</h1>
        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <p>View user questionnaire responses</p>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => {
                setViewMode('latest');
                fetchQuestionnaires();
              }}
              className={viewMode === 'latest' ? 'active-btn' : 'inactive-btn'}
              style={{
                padding: '6px 12px',
                border: '1px solid #ddd',
                borderRadius: '4px',
                cursor: 'pointer',
                backgroundColor: viewMode === 'latest' ? '#3498db' : 'white',
                color: viewMode === 'latest' ? 'white' : '#333',
              }}
            >
              Latest Only
            </button>
            <button
              onClick={() => {
                setViewMode('all');
                fetchQuestionnaires();
              }}
              className={viewMode === 'all' ? 'active-btn' : 'inactive-btn'}
              style={{
                padding: '6px 12px',
                border: '1px solid #ddd',
                borderRadius: '4px',
                cursor: 'pointer',
                backgroundColor: viewMode === 'all' ? '#3498db' : 'white',
                color: viewMode === 'all' ? 'white' : '#333',
              }}
            >
              All Entries
            </button>
          </div>
          <button onClick={fetchQuestionnaires} className="refresh-btn">
            Refresh
          </button>
        </div>
      </div>
      
      <div className="questionnaire-content">
        {questionnaires.length === 0 ? (
          <div className="no-data">
            <p>No questionnaires found.</p>
            <p>Users need to complete the questionnaire in the Flutter app.</p>
          </div>
        ) : (
          <div className="questionnaires-list">
            {questionnaires.map((item, index) => {
              const q = item.questionnaire || item;
              const formattedData = formatQuestionnaireData(q);
              const completedDate = item.latestDate || item.createdAt || q.createdAt;
              
              return (
                <div key={item.id || `${item.userId}-${index}`} className="questionnaire-card">
                  <div className="questionnaire-header">
                    <div>
                      <h3>{item.userName}</h3>
                      <p className="user-email">{item.userEmail}</p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      {completedDate && (
                        <p style={{ margin: 0, fontSize: '12px', color: '#666' }}>
                          {new Date(completedDate.seconds * 1000).toLocaleDateString()}
                        </p>
                      )}
                      {item.totalEntries > 1 && (
                        <p style={{ margin: '4px 0 0 0', fontSize: '11px', color: '#999' }}>
                          {item.totalEntries} entries total
                        </p>
                      )}
                    </div>
                  </div>
                  
                  <div className="questionnaire-details">
                    <div className="questionnaire-grid">
                      {formattedData.map((item, idx) => (
                        <div 
                          key={idx} 
                          className={`data-item ${item.important ? 'important' : ''}`}
                        >
                          <span className="data-label">{item.label}:</span>
                          <span className="data-value">{item.value}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default QuestionnaireManagement;

