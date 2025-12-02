import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Firebase configuration - using the same as Flutter app
const firebaseConfig = {
  apiKey: 'AIzaSyAxEoJyEnJlnG_7o8vtkrntXAaPn8wKqX8',
  authDomain: 'fypproject-7b63c.firebaseapp.com',
  projectId: 'fypproject-7b63c',
  storageBucket: 'fypproject-7b63c.firebasestorage.app',
  messagingSenderId: '973967383392',
  appId: '1:973967383392:web:05361b0e949f1b4f341c05',
  measurementId: 'G-CQ4GNTL1QB',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;

