import React, { useState } from 'react';
import { collection, getDocs, doc, getDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import './Export.css';

const Export = () => {
  const [exporting, setExporting] = useState(false);
  const [exportType, setExportType] = useState('all');
  const [status, setStatus] = useState('');

  const exportToCSV = (data, filename) => {
    if (!data || data.length === 0) {
      setStatus('❌ No data to export');
      return;
    }

    // Get headers from first object
    const headers = Object.keys(data[0]);
    
    // Create CSV content
    const csvContent = [
      headers.join(','),
      ...data.map(row => 
        headers.map(header => {
          const value = row[header];
          // Handle arrays and objects
          if (Array.isArray(value)) {
            return `"${value.join('; ')}"`;
          }
          if (value && typeof value === 'object') {
            return `"${JSON.stringify(value)}"`;
          }
          // Handle dates
          if (value && value.seconds) {
            return new Date(value.seconds * 1000).toISOString();
          }
          // Escape quotes and wrap in quotes
          return `"${String(value || '').replace(/"/g, '""')}"`;
        }).join(',')
      )
    ].join('\n');

    // Create blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    setStatus(`✅ Exported ${data.length} records to ${filename}`);
  };

  const exportToJSON = (data, filename) => {
    if (!data || data.length === 0) {
      setStatus('❌ No data to export');
      return;
    }

    const jsonContent = JSON.stringify(data, null, 2);
    const blob = new Blob([jsonContent], { type: 'application/json' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    setStatus(`✅ Exported ${data.length} records to ${filename}`);
  };

  const exportUsers = async () => {
    try {
      setStatus('📊 Fetching users...');
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const users = [];

      for (const userDoc of usersSnapshot.docs) {
        const data = userDoc.data();
        if (data.email || data.displayName) {
          // Get name from questionnaire
          let userName = data.displayName || 'No name';
          try {
            const onboardingSnapshot = await getDocs(
              collection(db, 'users', userDoc.id, 'onboarding')
            );
            if (onboardingSnapshot.docs.length > 0) {
              const sortedDocs = onboardingSnapshot.docs.sort((a, b) => {
                const aTime = a.data().createdAt?.seconds || 0;
                const bTime = b.data().createdAt?.seconds || 0;
                return bTime - aTime;
              });
              const latestOnboarding = sortedDocs[0].data();
              if (latestOnboarding.name) {
                userName = latestOnboarding.name;
              }
            }
          } catch (e) {
            // Ignore
          }

          users.push({
            userId: userDoc.id,
            email: data.email || '',
            name: userName,
            displayName: data.displayName || '',
            platform: data.platform || '',
            provider: data.provider || '',
            createdAt: data.createdAt,
            lastLogin: data.lastLogin,
          });
        }
      }

      return users;
    } catch (error) {
      console.error('Error exporting users:', error);
      throw error;
    }
  };

  const exportColorAnalyses = async () => {
    try {
      setStatus('🎨 Fetching color analyses...');
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const analyses = [];

      for (const userDoc of usersSnapshot.docs) {
        try {
          const analysisDoc = await getDoc(
            doc(db, 'users', userDoc.id, 'analysis', 'latest')
          );
          
          if (analysisDoc.exists()) {
            const analysisData = analysisDoc.data();
            const analysis = analysisData.analysis || analysisData;
            const skinTone = analysis.skin_tone || analysis.skinTone || {};
            const colorRecs = analysis.color_recommendations || analysis.colorRecommendations || {};

            analyses.push({
              userId: userDoc.id,
              userEmail: userDoc.data().email || '',
              skinToneCategory: skinTone.category || '',
              skinToneUndertone: skinTone.undertone || '',
              fitzpatrickType: skinTone.fitzpatrick_type || skinTone.fitzpatrickType || '',
              bestColors: (colorRecs.best_colors || []).join('; '),
              avoidColors: (colorRecs.avoid_colors || []).join('; '),
              neutrals: (colorRecs.neutrals || []).join('; '),
              analyzedAt: analysisData.createdAt,
            });
          }
        } catch (error) {
          // Continue
        }
      }

      return analyses;
    } catch (error) {
      console.error('Error exporting color analyses:', error);
      throw error;
    }
  };

  const exportClosetItems = async () => {
    try {
      setStatus('👔 Fetching closet items...');
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const items = [];

      for (const userDoc of usersSnapshot.docs) {
        try {
          const closetSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'closet_items')
          );
          
          closetSnapshot.docs.forEach((itemDoc) => {
            const data = itemDoc.data();
            items.push({
              itemId: itemDoc.id,
              userId: userDoc.id,
              userEmail: userDoc.data().email || '',
              title: data.title || '',
              type: data.type || '',
              suitability: data.suitability || 0,
              colorScore: data.colorScore || 0,
              shapeScore: data.shapeScore || 0,
              fitScore: data.fitScore || 0,
              imageUrl: data.imageUrl || '',
              createdAt: data.createdAt,
            });
          });
        } catch (error) {
          // Continue
        }
      }

      return items;
    } catch (error) {
      console.error('Error exporting closet items:', error);
      throw error;
    }
  };

  const exportQuestionnaires = async () => {
    try {
      setStatus('📝 Fetching questionnaires...');
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const questionnaires = [];

      for (const userDoc of usersSnapshot.docs) {
        try {
          const onboardingSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'onboarding')
          );
          
          onboardingSnapshot.docs.forEach((qDoc) => {
            const data = qDoc.data();
            questionnaires.push({
              questionnaireId: qDoc.id,
              userId: userDoc.id,
              userEmail: userDoc.data().email || '',
              name: data.name || '',
              heightCm: data.heightCm || '',
              weightKg: data.weightKg || '',
              bodyType: data.bodyType || '',
              sizeRange: data.sizeRange || '',
              fitPrefs: Array.isArray(data.fitPrefs) ? data.fitPrefs.join('; ') : '',
              styleGoal: data.styleGoal || '',
              completedAt: data.createdAt,
            });
          });
        } catch (error) {
          // Continue
        }
      }

      return questionnaires;
    } catch (error) {
      console.error('Error exporting questionnaires:', error);
      throw error;
    }
  };

  const handleExport = async (format) => {
    setExporting(true);
    setStatus('🔄 Preparing export...');

    try {
      let data = [];
      let filename = '';

      switch (exportType) {
        case 'users':
          data = await exportUsers();
          filename = `users_export_${new Date().toISOString().split('T')[0]}.${format}`;
          break;
        case 'color-analyses':
          data = await exportColorAnalyses();
          filename = `color_analyses_export_${new Date().toISOString().split('T')[0]}.${format}`;
          break;
        case 'closet-items':
          data = await exportClosetItems();
          filename = `closet_items_export_${new Date().toISOString().split('T')[0]}.${format}`;
          break;
        case 'questionnaires':
          data = await exportQuestionnaires();
          filename = `questionnaires_export_${new Date().toISOString().split('T')[0]}.${format}`;
          break;
        case 'all':
          // Export all data
          const [users, analyses, items, questionnaires] = await Promise.all([
            exportUsers(),
            exportColorAnalyses(),
            exportClosetItems(),
            exportQuestionnaires(),
          ]);
          
          const allData = {
            exportDate: new Date().toISOString(),
            summary: {
              totalUsers: users.length,
              totalAnalyses: analyses.length,
              totalClosetItems: items.length,
              totalQuestionnaires: questionnaires.length,
            },
            users,
            colorAnalyses: analyses,
            closetItems: items,
            questionnaires,
          };
          
          filename = `vogue_ai_complete_export_${new Date().toISOString().split('T')[0]}.${format}`;
          
          if (format === 'json') {
            exportToJSON(allData, filename);
          } else {
            // For CSV, export each section separately
            exportToCSV(users, `users_export_${new Date().toISOString().split('T')[0]}.csv`);
            setTimeout(() => exportToCSV(analyses, `color_analyses_export_${new Date().toISOString().split('T')[0]}.csv`), 500);
            setTimeout(() => exportToCSV(items, `closet_items_export_${new Date().toISOString().split('T')[0]}.csv`), 1000);
            setTimeout(() => exportToCSV(questionnaires, `questionnaires_export_${new Date().toISOString().split('T')[0]}.csv`), 1500);
            setStatus(`✅ Exported all data (4 files downloaded)`);
            setExporting(false);
            return;
          }
          data = allData;
          break;
        default:
          setStatus('❌ Invalid export type');
          setExporting(false);
          return;
      }

      if (format === 'csv') {
        exportToCSV(data, filename);
      } else {
        exportToJSON(data, filename);
      }
    } catch (error) {
      console.error('Export error:', error);
      setStatus(`❌ Export failed: ${error.message}`);
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="export-page">
      <div className="page-header">
        <h1>Export Data</h1>
        <p>Export user data and analytics to CSV or JSON</p>
      </div>
      
      <div className="export-content">
        <div className="export-options">
          <div className="option-group">
            <h3>Select Data to Export</h3>
            <div className="radio-group">
              <label>
                <input
                  type="radio"
                  value="all"
                  checked={exportType === 'all'}
                  onChange={(e) => setExportType(e.target.value)}
                />
                <span>All Data (Complete Export)</span>
              </label>
              <label>
                <input
                  type="radio"
                  value="users"
                  checked={exportType === 'users'}
                  onChange={(e) => setExportType(e.target.value)}
                />
                <span>Users Only</span>
              </label>
              <label>
                <input
                  type="radio"
                  value="color-analyses"
                  checked={exportType === 'color-analyses'}
                  onChange={(e) => setExportType(e.target.value)}
                />
                <span>Color Analyses</span>
              </label>
              <label>
                <input
                  type="radio"
                  value="closet-items"
                  checked={exportType === 'closet-items'}
                  onChange={(e) => setExportType(e.target.value)}
                />
                <span>Closet Items</span>
              </label>
              <label>
                <input
                  type="radio"
                  value="questionnaires"
                  checked={exportType === 'questionnaires'}
                  onChange={(e) => setExportType(e.target.value)}
                />
                <span>Questionnaires</span>
              </label>
            </div>
          </div>

          <div className="export-buttons">
            <button
              onClick={() => handleExport('csv')}
              disabled={exporting}
              className="export-btn csv-btn"
            >
              {exporting ? 'Exporting...' : '📊 Export as CSV'}
            </button>
            <button
              onClick={() => handleExport('json')}
              disabled={exporting}
              className="export-btn json-btn"
            >
              {exporting ? 'Exporting...' : '📄 Export as JSON'}
            </button>
          </div>

          {status && (
            <div className={`status-message ${status.includes('✅') ? 'success' : status.includes('❌') ? 'error' : 'info'}`}>
              {status}
            </div>
          )}

          <div className="export-info">
            <h4>What gets exported:</h4>
            <ul>
              <li><strong>All Data:</strong> Complete export with all users, analyses, items, and questionnaires</li>
              <li><strong>Users:</strong> User profiles with email, name, dates, platform info</li>
              <li><strong>Color Analyses:</strong> Skin tone analysis and color recommendations</li>
              <li><strong>Closet Items:</strong> All items from user closets with scores</li>
              <li><strong>Questionnaires:</strong> All questionnaire responses</li>
            </ul>
            <p className="note">
              💡 <strong>Tip:</strong> CSV format is best for Excel/Sheets. JSON format is best for developers/data analysis.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Export;

