// Use v1p1beta1 for M4A/MP4 support
const speech = require('@google-cloud/speech').v1p1beta1;
const { Translate } = require('@google-cloud/translate').v2;
const fs = require('fs');
const path = require('path');
require('dotenv').config();

let speechClient = null;
let translateClient = null;

// Initialize clients lazily (on first use) to avoid blocking startup
// Support both file path and direct JSON credentials
function initializeGoogleClients() {
  if (speechClient && translateClient) {
    return; // Already initialized
  }

  try {
    const projectId = process.env.GOOGLE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT_ID;
    
    // Check if using service account key file path
    if (process.env.GOOGLE_STT_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      const keyPath = process.env.GOOGLE_STT_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS;
      process.env.GOOGLE_APPLICATION_CREDENTIALS = keyPath;
      speechClient = new speech.SpeechClient(); // v1p1beta1 supports M4A_AAC
      translateClient = new Translate({
        projectId: projectId
      });
    }
    // Check if using direct credentials (client_email and private_key)
    else if (process.env.GOOGLE_CLIENT_EMAIL && process.env.GOOGLE_PRIVATE_KEY && projectId) {
      const credentials = {
        type: 'service_account',
        project_id: projectId,
        private_key_id: process.env.GOOGLE_PRIVATE_KEY_ID || '',
        private_key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        client_email: process.env.GOOGLE_CLIENT_EMAIL,
        client_id: process.env.GOOGLE_CLIENT_ID || '',
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(process.env.GOOGLE_CLIENT_EMAIL)}`
      };
      
      speechClient = new speech.SpeechClient({ // v1p1beta1 supports M4A_AAC
        credentials: credentials,
        projectId: projectId
      });
      translateClient = new Translate({
        credentials: credentials,
        projectId: projectId
      });
    }
  } catch (error) {
    console.warn('⚠️  Google Cloud credentials not configured. Audio processing will be limited.');
    console.warn('   Error:', error.message);
  }
}

/**
 * Detect language of audio (simplified - you may want to use a more sophisticated method)
 */
async function detectLanguage(audioBuffer) {
  // For now, return 'en' as default
  // In production, you might use Google Cloud Speech API's language detection
  // or a separate language detection service
  return 'en';
}

/**
 * Transcribe audio to text
 */
async function transcribeAudio(audioBuffer, languageCode = 'en-US') {
  initializeGoogleClients(); // Initialize on first use
  if (!speechClient) {
    throw new Error('Speech client not initialized. Please configure GOOGLE_APPLICATION_CREDENTIALS.');
  }

  try {
    // Try to detect audio format from buffer
    // M4A files start with specific bytes
    let encoding = 'LINEAR16'; // Default
    let sampleRate = 44100; // Default
    
    // Check if it's M4A/AAC format (common from mobile recorders)
    // M4A files typically start with 'ftyp' (66747970) or have 'M4A' in header
    if (audioBuffer.length > 12) {
      const header = audioBuffer.slice(0, 12).toString('hex');
      const headerStr = audioBuffer.slice(0, 12).toString('ascii', 0, 12);
      
      if (header.includes('66747970') || headerStr.includes('M4A') || headerStr.includes('ftyp') || header.includes('6d7034')) {
        // M4A/AAC format - v1p1beta1 supports M4A_AAC encoding
        encoding = 'M4A_AAC';
        sampleRate = 44100;
      } else if (header.includes('52494646') || headerStr.includes('RIFF')) {
        // WAV format
        encoding = 'LINEAR16';
        sampleRate = 44100;
      } else if (headerStr.includes('Ogg') || header.includes('4f676753')) {
        // OGG format
        encoding = 'OGG_OPUS';
        sampleRate = 48000;
      } else {
        // Default to MP3 for mobile recordings (most common)
        encoding = 'MP3';
        sampleRate = 44100;
      }
    }

    // Build config object - M4A_AAC doesn't require sampleRateHertz
    const config = {
      encoding: encoding,
      languageCode: languageCode,
      alternativeLanguageCodes: ['en-US', 'hi-IN', 'te-IN'], // Support multiple languages
      enableAutomaticPunctuation: true,
    };

    // Add sampleRateHertz only for encodings that require it
    // M4A_AAC can auto-detect sample rate
    if (encoding !== 'M4A_AAC' && encoding !== 'MP4_AAC' && encoding !== 'MP3') {
      config.sampleRateHertz = sampleRate;
    } else if (encoding === 'MP3') {
      config.sampleRateHertz = sampleRate;
    }

    const request = {
      audio: {
        content: audioBuffer.toString('base64'),
      },
      config: config,
    };

    console.log('Sending transcription request:', {
      encoding: encoding,
      sampleRate: config.sampleRateHertz || 'auto',
      languageCode,
      bufferSize: audioBuffer.length
    });

    const [response] = await speechClient.recognize(request);
    
    if (!response.results || response.results.length === 0) {
      console.warn('No transcription results returned');
      throw new Error('No speech detected in audio file');
    }

    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join(' ');

    if (!transcription || transcription.trim() === '') {
      throw new Error('Empty transcription result');
    }

    console.log('Transcription successful:', transcription.substring(0, 100));
    return transcription;
  } catch (error) {
    console.error('Transcription error:', error);
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    if (error.details) {
      console.error('Error details:', error.details);
    }
    throw error;
  }
}

/**
 * Translate text to English
 */
async function translateToEnglish(text, sourceLanguage) {
  initializeGoogleClients(); // Initialize on first use
  if (!translateClient) {
    throw new Error('Translate client not initialized.');
  }

  try {
    const [translation] = await translateClient.translate(text, {
      from: sourceLanguage,
      to: 'en',
    });
    return translation;
  } catch (error) {
    console.error('Translation error:', error);
    throw error;
  }
}

/**
 * Process audio: detect language, translate if needed, then transcribe
 */
async function processAudio(audioBuffer) {
  try {
    // Detect language
    const detectedLang = await detectLanguage(audioBuffer);
    
    let rawTranscript = '';
    let translatedTranscript = '';

    if (detectedLang === 'en' || detectedLang.startsWith('en')) {
      // Direct transcription for English
      rawTranscript = await transcribeAudio(audioBuffer, 'en-US');
      translatedTranscript = rawTranscript; // Same for English
    } else {
      // For non-English: Translate first, then transcribe
      // Note: This is a simplified flow. In practice, you might transcribe first
      // then translate the transcript, or use a different approach
      
      // Transcribe in original language
      rawTranscript = await transcribeAudio(audioBuffer, `${detectedLang}-${detectedLang.toUpperCase()}`);
      
      // Translate to English
      translatedTranscript = await translateToEnglish(rawTranscript, detectedLang);
    }

    return {
      rawTranscript,
      translatedTranscript,
      detectedLanguage: detectedLang
    };
  } catch (error) {
    console.error('Audio processing error:', error);
    throw error;
  }
}

module.exports = {
  processAudio,
  transcribeAudio,
  translateToEnglish,
  detectLanguage
};
