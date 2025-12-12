// Script to update AndroidManifest.xml with Google Maps API key from .env
// This should be run before building the Flutter app

const fs = require('fs');
const path = require('path');
require('dotenv').config();

const manifestPath = path.join(__dirname, '../../frontend/android/app/src/main/AndroidManifest.xml');

if (!process.env.GOOGLE_MAPS) {
  console.warn('⚠️  GOOGLE_MAPS not set in .env file');
  console.warn('   Maps will not work without a Google Maps API key');
  process.exit(0);
}

try {
  let manifest = fs.readFileSync(manifestPath, 'utf8');
  
  // Check if Google Maps API key is already set
  if (manifest.includes('com.google.android.geo.API_KEY')) {
    // Replace existing key
    manifest = manifest.replace(
      /android:name="com\.google\.android\.geo\.API_KEY"\s+android:value="[^"]*"/,
      `android:name="com.google.android.geo.API_KEY" android:value="${process.env.GOOGLE_MAPS}"`
    );
  } else {
    // Uncomment and add the key
    manifest = manifest.replace(
      /<!--\s*Google Maps API Key.*?-->/s,
      `<meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${process.env.GOOGLE_MAPS}"/>`
    );
  }
  
  fs.writeFileSync(manifestPath, manifest, 'utf8');
  console.log('✅ AndroidManifest.xml updated with Google Maps API key');
} catch (error) {
  console.error('❌ Error updating AndroidManifest.xml:', error.message);
  process.exit(1);
}
