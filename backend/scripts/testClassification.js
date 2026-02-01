/**
 * Verifies Gemini API and complaint classification as per prescribed logic:
 * - One keyword or same-department keywords → direct assign
 * - Multiple departments or no keywords → Gemini picks from allowed list
 *
 * Run: node scripts/testClassification.js
 * Requires: .env with GEMINI_API_KEY or GEMINI_KEY
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { classifyDepartment, DEPARTMENTS } = require('../utils/aiClassification');

// Inline keyword check for test output only (mirrors aiClassification logic)
const KEYWORDS = {
  'GHMC Sanitation': ['garbage', 'trash', 'dustbin', 'dumping', 'waste', 'debris', 'cleaning', 'sweep', 'overflowing garbage'],
  'GHMC Road and Engineering': ['road', 'pothole', 'street', 'damaged road', 'construction', 'repair', 'footpath', 'pavement', 'manhole', 'culvert'],
  'HMWSSB': ['water', 'leak', 'pipeline', 'pipe burst', 'sewer', 'drain', 'drainage', 'sewage', 'overflowing drain', 'open drain', 'contaminated water', 'stagnant water'],
  'TSSPDCL': ['street light', 'electric', 'power cut', 'transformer', 'cable', 'wiring', 'pole', 'meter'],
  'GHMC Town Planning': ['illegal construction', 'encroachment', 'unauthorized building', 'demolition', 'structure', 'setback', 'hoarding'],
  'GHMC Public Health / Entomology': ['mosquito', 'dengue', 'malaria', 'pest', 'stray dog', 'animal bite', 'fogging']
};

function getMatchedDepartments(description) {
  const text = (description || '').toLowerCase();
  const matched = [];
  for (const [dept, keywords] of Object.entries(KEYWORDS)) {
    for (const kw of keywords) {
      if (text.includes(kw)) {
        matched.push(dept);
        break;
      }
    }
  }
  return [...new Set(matched)];
}

async function main() {
  const apiKey = process.env.GEMINI_API_KEY || process.env.GEMINI_KEY;

  console.log('========== 1. Gemini API key check ==========');
  if (!apiKey) {
    console.log('❌ No GEMINI_API_KEY or GEMINI_KEY in .env');
    process.exit(1);
  }
  console.log('✅ API key present (length:', apiKey.length, ')');

  console.log('\n========== 2. Raw Gemini API test ==========');
  try {
    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const genAI = new GoogleGenerativeAI(apiKey);
    const modelId = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
    const model = genAI.getGenerativeModel({ model: modelId });
    const result = await model.generateContent('Reply with exactly: Gemini API is working');
    const text = result.response.text();
    console.log('✅ Gemini response:', text.trim());
  } catch (e) {
    console.log('❌ Gemini API error:', e.message);
    process.exit(1);
  }

  const testCases = [
    { description: 'the road is filled with water causing foul smell', expected: 'HMWSSB' },
    { description: 'the road is having a large amount of mosquitoes', expected: 'GHMC Public Health / Entomology' },
    { description: 'the road is stopped due to illegal construction of unauthorized buildings', expected: 'GHMC Town Planning' },
    { description: 'There is a foul smell coming from the open drain and garbage is piling up around it.', expected: 'HMWSSB' },
    { description: 'The road has been dug up for pipeline repair and has not been restored properly for weeks.', expected: 'GHMC Road and Engineering' },
    { description: 'A broken electric pole is leaning over the road and posing a serious danger to pedestrians.', expected: 'TSSPDCL' }
  ];

  for (let i = 0; i < testCases.length; i++) {
    const { description: testDescription, expected } = testCases[i];
    console.log('\n========== Test ' + (i + 1) + ': ' + testDescription.slice(0, 50) + '... ==========');
    const matched = getMatchedDepartments(testDescription);
    console.log('Matched departments (keywords):', matched.length ? matched.join(', ') : '(none)');
    if (matched.length === 1) console.log('→ Logic: single department → direct assign');
    else if (matched.length > 1) console.log('→ Logic: multiple departments → Gemini picks one');
    else console.log('→ Logic: no keywords → Gemini picks one');

    try {
      const out = await classifyDepartment(testDescription);
      console.log('Result:', out.department, '|', out.problem_type);
      console.log(out.department === expected ? '✅ Correct' : '⚠️  Expected: ' + expected);
    } catch (e) {
      console.log('❌ Error:', e.message);
    }
  }

  console.log('\n========== 5. Allowed departments list ==========');
  console.log(DEPARTMENTS.join(', '));
  console.log('\nDone.');
}

main();
