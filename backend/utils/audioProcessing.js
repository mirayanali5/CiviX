const speech = require('@google-cloud/speech').v1;
const { Translate } = require('@google-cloud/translate').v2;
const fs = require('fs');
const path = require('path');
require('dotenv').config();

let speechClient = null;
let translateClient = null;

// Initialize clients if credentials are available
// Support both file path and direct JSON credentials
try {
  const projectId = process.env.GOOGLE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT_ID;
  
  // Check if using service account key file path
  if (process.env.GOOGLE_STT_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const keyPath = process.env.GOOGLE_STT_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS;
    process.env.GOOGLE_APPLICATION_CREDENTIALS = keyPath;
    speechClient = new speech.SpeechClient();
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
    
    speechClient = new speech.SpeechClient({
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
  if (!speechClient) {
    throw new Error('Speech client not initialized. Please configure GOOGLE_APPLICATION_CREDENTIALS.');
  }

  try {
    const request = {
      audio: {
        content: audioBuffer.toString('base64'),
      },
      config: {
        encoding: 'WEBM_OPUS', // Adjust based on your audio format
        sampleRateHertz: 48000,
        languageCode: languageCode,
      },
    };

    const [response] = await speechClient.recognize(request);
    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join(' ');

    return transcription;
  } catch (error) {
    console.error('Transcription error:', error);
    throw error;
  }
}

/**
 * Translate text to English
 */
async function translateToEnglish(text, sourceLanguage) {
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
