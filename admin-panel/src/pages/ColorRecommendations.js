import React, { useState, useEffect } from 'react';
import { collection, getDocs, doc, getDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import './ColorRecommendations.css';

const ColorRecommendations = () => {
  const [analyses, setAnalyses] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchColorAnalyses();
  }, []);

  const fetchColorAnalyses = async () => {
    try {
      console.log('🎨 Fetching color analyses...');
      
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const allAnalyses = [];

      // For each user, get their color analysis
      for (const userDoc of usersSnapshot.docs) {
        try {
          const userData = userDoc.data();
          
          // Get user name from questionnaire
          let userName = userData.displayName || 'No name';
          try {
            const onboardingSnapshot = await getDocs(
              collection(db, 'users', userDoc.id, 'onboarding')
            );
            if (onboardingSnapshot.docs.length > 0) {
              // Get latest onboarding to find name
              const sortedDocs = onboardingSnapshot.docs.sort((a, b) => {
                const aTime = a.data().createdAt?.seconds || 0;
                const bTime = b.data().createdAt?.seconds || 0;
                return bTime - aTime;
              });
              const latestOnboarding = sortedDocs[0].data();
              if (latestOnboarding.name && latestOnboarding.name.trim() !== '') {
                userName = latestOnboarding.name;
              }
            }
          } catch (e) {
            console.log(`⚠️ Could not fetch name for user ${userDoc.id}`);
          }
          
          // Try to get latest analysis
          const analysisDoc = await getDoc(
            doc(db, 'users', userDoc.id, 'analysis', 'latest')
          );
          
          if (analysisDoc.exists()) {
            const analysisData = analysisDoc.data();
            allAnalyses.push({
              userId: userDoc.id,
              userEmail: userData.email || 'Unknown',
              userName: userName,
              analysis: analysisData.analysis || analysisData,
              imagePath: analysisData.imagePath || '',
              createdAt: analysisData.createdAt,
            });
          }
        } catch (error) {
          console.log(`⚠️ Error fetching analysis for user ${userDoc.id}:`, error.message);
        }
      }

      // Sort by latest first
      allAnalyses.sort((a, b) => {
        const aTime = a.createdAt?.seconds || 0;
        const bTime = b.createdAt?.seconds || 0;
        return bTime - aTime;
      });

      console.log(`✅ Found ${allAnalyses.length} color analyses`);
      setAnalyses(allAnalyses);
    } catch (error) {
      console.error('❌ Error fetching color analyses:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="page-loading">Loading color analyses...</div>;
  }

  return (
    <div className="color-page">
      <div className="page-header">
        <h1>Color Recommendations</h1>
        <p>View color analyses and recommendations by user</p>
        <button onClick={fetchColorAnalyses} className="refresh-btn">
          Refresh
        </button>
      </div>
      
      <div className="color-content">
        {analyses.length === 0 ? (
          <div className="no-data">
            <p>No color analyses found.</p>
            <p>Users need to complete color analysis in the Flutter app.</p>
          </div>
        ) : (
          <div className="analyses-list">
            {analyses.map((analysis, index) => {
              const skinTone = analysis.analysis?.skin_tone || analysis.analysis?.skinTone || {};
              const colorRecs = analysis.analysis?.color_recommendations || analysis.analysis?.colorRecommendations || {};
              
              return (
                <div key={index} className="analysis-card">
                  <div className="analysis-header">
                    <h3>{analysis.userName}</h3>
                    <p className="user-email">{analysis.userEmail}</p>
                  </div>
                  
                  <div className="analysis-details">
                    <div className="detail-section">
                      <h4>Skin Tone</h4>
                      <p><strong>Category:</strong> {skinTone.category || 'N/A'}</p>
                      <p><strong>Undertone:</strong> {skinTone.undertone || 'N/A'}</p>
                      <p><strong>Fitzpatrick Type:</strong> {skinTone.fitzpatrick_type || skinTone.fitzpatrickType || 'N/A'}</p>
                    </div>
                    
                    {colorRecs.best_colors && colorRecs.best_colors.length > 0 && (
                      <div className="detail-section">
                        <h4>🌈 Best Colors</h4>
                        <div className="color-tags">
                          {colorRecs.best_colors.map((color, i) => (
                            <span key={i} className="color-tag best" title={color}>
                              {color}
                            </span>
                          ))}
                        </div>
                        <p className="color-count">{colorRecs.best_colors.length} recommended colors</p>
                      </div>
                    )}
                    
                    {colorRecs.avoid_colors && colorRecs.avoid_colors.length > 0 && (
                      <div className="detail-section">
                        <h4>❌ Colors to Avoid</h4>
                        <div className="color-tags">
                          {colorRecs.avoid_colors.map((color, i) => (
                            <span key={i} className="color-tag avoid" title={color}>
                              {color}
                            </span>
                          ))}
                        </div>
                        <p className="color-count">{colorRecs.avoid_colors.length} colors to avoid</p>
                      </div>
                    )}
                    
                    {colorRecs.neutrals && colorRecs.neutrals.length > 0 && (
                      <div className="detail-section">
                        <h4>⚪ Neutral Colors</h4>
                        <div className="color-tags">
                          {colorRecs.neutrals.map((color, i) => (
                            <span key={i} className="color-tag neutral" title={color}>
                              {color}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                    
                    {colorRecs.description && (
                      <div className="detail-section">
                        <h4>📝 Description</h4>
                        <p className="description-text">{colorRecs.description}</p>
                      </div>
                    )}
                    
                    {analysis.createdAt && (
                      <p className="analysis-date">
                        Analyzed: {new Date(analysis.createdAt.seconds * 1000).toLocaleDateString()}
                      </p>
                    )}
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

export default ColorRecommendations;

