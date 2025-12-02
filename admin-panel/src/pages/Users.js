import React, { useState, useEffect } from 'react';
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore';
import { db } from '../config/firebase';
import './Users.css';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      console.log('📊 Fetching users...');
      
      // Get all users (without orderBy to avoid errors if createdAt is missing)
      const snapshot = await getDocs(collection(db, 'users'));
      const usersDocs = snapshot.docs.filter(doc => {
        const data = doc.data();
        return data.email || data.displayName; // Only users with data
      });
      
      // Fetch name from questionnaire for each user
      const usersData = await Promise.all(
        usersDocs.map(async (doc) => {
          const data = doc.data();
          let userName = data.displayName || 'No name';
          
          // Try to get name from questionnaire/onboarding
          try {
            const onboardingSnapshot = await getDocs(
              collection(db, 'users', doc.id, 'onboarding')
            );
            
            // Get the latest onboarding document (should have the name)
            if (onboardingSnapshot.docs.length > 0) {
              // Sort by createdAt to get the latest
              const sortedDocs = onboardingSnapshot.docs.sort((a, b) => {
                const aTime = a.data().createdAt?.seconds || 0;
                const bTime = b.data().createdAt?.seconds || 0;
                return bTime - aTime; // Latest first
              });
              
              const latestOnboarding = sortedDocs[0].data();
              if (latestOnboarding.name && latestOnboarding.name.trim() !== '') {
                userName = latestOnboarding.name;
                console.log(`✅ Found name from questionnaire for ${data.email}: ${userName}`);
              }
            }
          } catch (error) {
            console.log(`⚠️ Could not fetch onboarding for user ${doc.id}:`, error.message);
          }
          
          return {
        id: doc.id,
            email: data.email || 'No email',
            displayName: userName, // Use name from questionnaire
            createdAt: data.createdAt,
            lastLogin: data.lastLogin,
            platform: data.platform || 'unknown',
            provider: data.provider || 'unknown',
            hasData: true,
          };
        })
      );
      
      // Sort users
      usersData.sort((a, b) => {
        // Sort by createdAt if available, otherwise by email
        if (a.createdAt && b.createdAt) {
          return b.createdAt.seconds - a.createdAt.seconds;
        }
        return (a.email || '').localeCompare(b.email || '');
      });
      
      console.log(`✅ Found ${usersData.length} users with data`);
      setUsers(usersData);
    } catch (error) {
      console.error('❌ Error fetching users:', error);
      // Try without orderBy as fallback
      try {
        const snapshot = await getDocs(collection(db, 'users'));
        const usersData = snapshot.docs
          .map((doc) => ({
            id: doc.id,
            ...doc.data(),
          }))
          .filter((user) => user.email || user.displayName);
        setUsers(usersData);
      } catch (fallbackError) {
        console.error('❌ Fallback also failed:', fallbackError);
      }
    } finally {
      setLoading(false);
    }
  };

  const filteredUsers = users.filter((user) =>
    user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.displayName?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return <div className="page-loading">Loading users...</div>;
  }

  return (
    <div className="users-page">
      <div className="page-header">
        <h1>Users Management</h1>
        <div className="header-actions">
          <input
            type="text"
            placeholder="Search users..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      <div className="users-table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>Email</th>
              <th>Display Name</th>
              <th>Created At</th>
              <th>Last Login</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.length === 0 ? (
              <tr>
                <td colSpan="5" className="no-data">
                  No users found
                </td>
              </tr>
            ) : (
              filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>{user.email || 'N/A'}</td>
                  <td>{user.displayName || 'N/A'}</td>
                  <td>
                    {user.createdAt
                      ? new Date(user.createdAt.seconds * 1000).toLocaleDateString()
                      : 'N/A'}
                  </td>
                  <td>
                    {user.lastLogin
                      ? new Date(user.lastLogin.seconds * 1000).toLocaleDateString()
                      : 'N/A'}
                  </td>
                  <td>
                    <button className="action-btn view-btn">View</button>
                    <button className="action-btn delete-btn">Delete</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Users;

