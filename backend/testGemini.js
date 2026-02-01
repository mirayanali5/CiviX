const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

(async () => {
  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    // ✅ This model IS available in AI Studio
    const modelId = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
    const model = genAI.getGenerativeModel({ model: modelId });

    const result = await model.generateContent(
      'Reply with exactly: Gemini API is working'
    );

    console.log('✅', result.response.text());
  } catch (e) {
    console.error('❌ Gemini error:', e.message);
  }
})();
