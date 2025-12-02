import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth';
import { auth } from '../config/firebase';

const AuthContext = createContext();

// Admin email check - update with your admin emails
const ADMIN_EMAILS = [
  'admin@vogueai.com',
  'admin@gmail.com',
  'admin@12gmail.com',        // Admin from Firebase console
  'test@example.com',          // Test user
  'ahsan@gmail.com',           // User from Firebase
  'abdullah8@gmail.com',       // User from Firebase
  'ahmed@gmail.com',          // User from Firebase
  'unaiza100@gmail.com',       // User from Firebase
  'unaiza1mukhdoom@gmail.com', // User from Firebase
  'ali@gmail.com',             // User from Firebase
  // Add more admin emails here
];

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);

  function login(email, password) {
    console.log('Attempting login with email:', email);
    console.log('Admin emails allowed:', ADMIN_EMAILS);
    
    return signInWithEmailAndPassword(auth, email, password)
      .then((userCredential) => {
        const user = userCredential.user;
        console.log('Firebase authentication successful. User email:', user.email);
        
        // Check if user is admin
        if (!ADMIN_EMAILS.includes(user.email)) {
          console.log('User email not in admin list. Signing out...');
          signOut(auth);
          throw new Error('Access denied. Admin privileges required. Your email must be in the admin list.');
        }
        console.log('Admin check passed. Login successful.');
        return userCredential;
      })
      .catch((error) => {
        console.error('Login error:', error.code, error.message);
        
        // Handle Firebase authentication errors
        let errorMessage = 'Failed to login. Please try again.';
        
        switch (error.code) {
          case 'auth/invalid-credential':
          case 'auth/wrong-password':
          case 'auth/user-not-found':
            errorMessage = 'Invalid email or password. Please check your credentials. Make sure the user exists in Firebase Authentication.';
            break;
          case 'auth/invalid-email':
            errorMessage = 'Invalid email address. Please check your email format.';
            break;
          case 'auth/user-disabled':
            errorMessage = 'This account has been disabled. Please contact support.';
            break;
          case 'auth/too-many-requests':
            errorMessage = 'Too many failed login attempts. Please try again later.';
            break;
          case 'auth/network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          default:
            errorMessage = error.message || 'An error occurred during login.';
        }
        
        throw new Error(errorMessage);
      });
  }

  function logout() {
    return signOut(auth);
  }

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user && ADMIN_EMAILS.includes(user.email)) {
        setCurrentUser(user);
      } else {
        setCurrentUser(null);
      }
      setLoading(false);
    });

    return unsubscribe;
  }, [ADMIN_EMAILS]);

  const value = {
    currentUser,
    login,
    logout,
    loading,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

