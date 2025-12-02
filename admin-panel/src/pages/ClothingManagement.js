import React, { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import './ClothingManagement.css';

const ClothingManagement = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchClothingItems();
  }, []);

  const fetchClothingItems = async () => {
    try {
      console.log('👔 Fetching clothing items...');
      
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const allItems = [];

      // For each user, get their closet items
      for (const userDoc of usersSnapshot.docs) {
        try {
          const closetSnapshot = await getDocs(
            collection(db, 'users', userDoc.id, 'closet_items')
          );
          
          closetSnapshot.docs.forEach((itemDoc) => {
            allItems.push({
              id: itemDoc.id,
              userId: userDoc.id,
              userEmail: userDoc.data().email || 'Unknown',
              ...itemDoc.data(),
            });
          });
        } catch (error) {
          console.log(`⚠️ Error fetching items for user ${userDoc.id}:`, error.message);
        }
      }

      console.log(`✅ Found ${allItems.length} clothing items`);
      setItems(allItems);
    } catch (error) {
      console.error('❌ Error fetching clothing items:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="page-loading">Loading clothing items...</div>;
  }

  return (
    <div className="clothing-page">
      <div className="page-header">
        <h1>Clothing Management</h1>
        <p>Manage clothing items from user closets</p>
        <button onClick={fetchClothingItems} className="refresh-btn">
          Refresh
        </button>
      </div>
      
      <div className="clothing-content">
        {items.length === 0 ? (
          <div className="no-data">
            <p>No clothing items found.</p>
            <p>Users need to add items to their closet in the Flutter app.</p>
          </div>
        ) : (
          <div className="items-grid">
            {items.map((item) => (
              <div key={item.id} className="item-card">
                {item.imageUrl && (
                  <img src={item.imageUrl} alt={item.title} className="item-image" />
                )}
                <div className="item-info">
                  <h3>{item.title || 'Untitled Item'}</h3>
                  <p><strong>Type:</strong> {item.type || 'N/A'}</p>
                  <p><strong>User:</strong> {item.userEmail}</p>
                  <p><strong>Suitability:</strong> {item.suitability || 0}%</p>
                  <p><strong>Color Score:</strong> {item.colorScore || 0}</p>
                  <p><strong>Shape Score:</strong> {item.shapeScore || 0}</p>
                  <p><strong>Fit Score:</strong> {item.fitScore || 0}</p>
                  {item.createdAt && (
                    <p className="item-date">
                      Added: {new Date(item.createdAt.seconds * 1000).toLocaleDateString()}
                    </p>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ClothingManagement;

