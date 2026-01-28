// Firebase Data Upload Script - Simplified Version
// Usage: node upload_to_firebase.js
// 
// This script reads your Firebase project ID from firebase.json
// and uploads the fertility tests guide data to Firestore.
//
// SETUP (One time only):
// 1. Install Firebase CLI: npm install -g firebase-tools
// 2. Login to Firebase: firebase login
// 3. Then just run: node upload_to_firebase.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Read project ID from firebase.json
function readProjectId() {
  try {
    const firebaseConfig = JSON.parse(fs.readFileSync('firebase.json', 'utf-8'));
    const projectId = firebaseConfig?.flutter?.platforms?.android?.default?.projectId;
    return projectId || 'migynaeblogs';
  } catch (error) {
    console.error('❌ Could not read firebase.json');
    return 'migynaeblogs'; // Fallback
  }
}

const projectId = readProjectId();

console.log(`\n📱 Firebase Project: ${projectId}\n`);

// Initialize Firebase with default credentials (uses GOOGLE_APPLICATION_CREDENTIALS env var)
try {

    var serviceAccount = require("./serviceAccountKey.json");

    admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
    });
} catch (error) {
  console.error('❌ Firebase initialization error:', error.message);
  console.log('\n⚠️  SETUP REQUIRED:\n');
  console.log('1. Install Firebase CLI:');
  console.log('   npm install -g firebase-tools\n');
  console.log('2. Login to Firebase:');
  console.log('   firebase login\n');
  console.log('3. Then run this script again:');
  console.log('   node upload_to_firebase.js\n');
  process.exit(1);
}

const db = admin.firestore();

async function uploadData() {
  try {
    console.log('📁 Reading firebase_data.json...');
    
    // Read the JSON file
    const dataPath = path.join(__dirname, 'firebase_data.json');
    const jsonData = JSON.parse(fs.readFileSync(dataPath, 'utf-8'));
    
    console.log('✅ JSON loaded successfully\n');
    console.log(`📊 Found blogs: ${Object.keys(jsonData.blogs).length}\n`);
    
    // Upload each blog
    for (const [blogId, blogData] of Object.entries(jsonData.blogs)) {
      console.log(`📝 Uploading blog: ${blogId}...`);
      
      // Upload to Firestore
      await db.collection('blogs').doc(blogId).set(blogData, { merge: true });
      
      console.log(`✅ Successfully uploaded: ${blogId}`);
      console.log(`   Title: ${blogData.title}`);
      console.log(`   Content Blocks: ${blogData.contentBlocks?.length || 0}`);
      console.log(`   Read Time: ${blogData.readTimeMinutes} mins\n`);
    }
    
    console.log('🎉 All data uploaded successfully!');
    console.log('\n✨ You can now run the Flutter app with: flutter run\n');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error uploading data:', error.message);
    console.log('\n⚠️  Troubleshooting:\n');
    console.log('- Make sure firebase_data.json exists in this directory');
    console.log('- Make sure firebase.json is valid');
    console.log('- Run: firebase login');
    console.log('- Check your internet connection\n');
    process.exit(1);
  }
}

// Run the upload
uploadData();
