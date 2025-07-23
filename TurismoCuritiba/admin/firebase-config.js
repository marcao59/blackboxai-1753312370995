const admin = require('firebase-admin');

const firebaseConfig = {
  apiKey: "AIzaSyA50JwotsjCqaTUOtidl-Q2d12mA5DgKa0",
  authDomain: "blackbox-turismo-curitiba.firebaseapp.com",
  projectId: "blackbox-turismo-curitiba",
  storageBucket: "blackbox-turismo-curitiba.firebasestorage.app",
  messagingSenderId: "308975092257",
  appId: "1:308975092257:web:8c4e75b65a197d489a5960"
};

try {
  // Initialize Firebase Admin SDK
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: firebaseConfig.projectId,
    storageBucket: firebaseConfig.storageBucket
  });
  
  console.log("Firebase Admin initialized successfully.");
} catch (error) {
  console.error("Erro ao inicializar Firebase Admin:", error);
  
  // Fallback initialization for development
  try {
    admin.initializeApp({
      projectId: firebaseConfig.projectId,
      storageBucket: firebaseConfig.storageBucket
    });
    console.log("Firebase Admin initialized with fallback method.");
  } catch (fallbackError) {
    console.error("Erro na inicialização de fallback:", fallbackError);
  }
}

// Firestore instance
const db = admin.firestore();

// Storage instance
const bucket = admin.storage().bucket();

// Auth instance
const auth = admin.auth();

module.exports = {
  admin,
  db,
  bucket,
  auth,
  firebaseConfig
};
