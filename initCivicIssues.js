const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // <- your Firebase service account

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'civix-5e5a7.appspot.com'
});

const db = admin.firestore();

// ✅ List of civic issues (fixed - single array, no extra nesting)
const civicIssues = [
  {
    "issue_name": "Potholes on road",
    "description": "Visible potholes or damaged road surface",
    "department": "GHMC",
    "responsible_agency": "GHMC - Roads & Engineering Wing",
    "routing_code": "GHMC_ROADS",
    "image_detectable": true
  },
  {
    "issue_name": "Damaged footpaths",
    "description": "Broken or uneven pedestrian paths",
    "department": "GHMC",
    "responsible_agency": "GHMC - Roads & Engineering Wing",
    "routing_code": "GHMC_FOOTPATHS",
    "image_detectable": true
  },
  {
    "issue_name": "Open/damaged manholes",
    "description": "Missing or broken manhole covers visible on streets",
    "department": "GHMC",
    "responsible_agency": "GHMC - Roads & Engineering Wing",
    "routing_code": "GHMC_MANHOLES",
    "image_detectable": true
  },
  {
    "issue_name": "Water stagnation / flooding",
    "description": "Pools of water or flooding on streets",
    "department": "GHMC",
    "responsible_agency": "GHMC - Roads & Engineering Wing",
    "routing_code": "GHMC_WATERLOGGING",
    "image_detectable": true
  },
  {
    "issue_name": "Garbage overflow",
    "description": "Dustbins overflowing or garbage piles on streets",
    "department": "GHMC",
    "responsible_agency": "GHMC - Sanitation / Solid Waste Management",
    "routing_code": "GHMC_GARBAGE",
    "image_detectable": true
  },
  // ... continue adding all remaining issues exactly as before
];

async function initCivicIssues() {
  console.log('Uploading civic issues to Firestore...');

  for (const issue of civicIssues) {
    if (!issue.routing_code || issue.routing_code.trim() === '') {
      console.warn('Skipping issue with missing routing_code:', issue.issue_name);
      continue;
    }

    try {
      await db.collection('civic_issues').doc(issue.routing_code).set(issue);
      console.log(`✅ Uploaded: ${issue.issue_name}`);
    } catch (error) {
      console.error(`❌ Failed to upload: ${issue.issue_name}`, error);
    }
  }

  console.log('🎉 All issues uploaded successfully!');
}

// Run the function
initCivicIssues().catch(console.error);
