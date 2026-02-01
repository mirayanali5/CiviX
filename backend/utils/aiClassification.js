const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

/* ===================== DEPARTMENTS ===================== */

const DEPARTMENTS = [
  'GHMC Sanitation',
  'GHMC Road and Engineering',
  'HMWSSB',
  'TSSPDCL',
  'GHMC Town Planning',
  'GHMC Public Health / Entomology'
];

/* ===================== KEYWORDS ===================== */
/*
  IMPORTANT DESIGN RULE:
  - Keywords must indicate PRIMARY responsibility
  - Avoid generic words like "smell" or "dirty"
*/

const KEYWORDS = {
  'GHMC Sanitation': [
    'garbage', 'trash', 'dustbin', 'dumping', 'waste',
    'debris', 'cleaning', 'sweep', 'overflowing garbage'
  ],

  'GHMC Road and Engineering': [
    'road', 'pothole', 'street', 'damaged road', 'construction',
    'repair', 'footpath', 'pavement', 'manhole', 'culvert'
  ],

  'HMWSSB': [
    'water', 'leak', 'pipeline', 'pipe burst', 'sewer',
    'drain', 'drainage', 'sewage', 'overflowing drain', 'contaminated water',
    'stagnant water', 'open drain'
  ],

  'TSSPDCL': [
    'street light', 'electric', 'power cut', 'transformer',
    'cable', 'wiring', 'pole', 'meter'
  ],

  'GHMC Town Planning': [
    'illegal construction', 'encroachment', 'unauthorized building',
    'demolition', 'structure', 'setback', 'hoarding'
  ],

  'GHMC Public Health / Entomology': [
    'mosquito', 'dengue', 'malaria', 'pest', 'stray dog',
    'animal bite', 'fogging'
  ]
};

/* ===================== MAIN CLASSIFIER ===================== */
/*
  PRESCRIBED LOGIC:
  - If description has ONLY ONE keyword OR multiple keywords from the SAME department
    → assign that department directly (no API call).
  - If description has keywords from MULTIPLE departments OR NO keywords
    → send description to Gemini with fixed prompt to pick the most appropriate department.
*/

async function classifyDepartment(description) {
  if (!description || typeof description !== 'string') {
    return { department: 'GHMC Sanitation', problem_type: 'General' };
  }

  const text = description.toLowerCase();

  /* ---- STEP 1: Collect all departments that have at least one keyword match ---- */

  const matchedDepartments = [];

  for (const [department, keywords] of Object.entries(KEYWORDS)) {
    for (const keyword of keywords) {
      if (text.includes(keyword)) {
        matchedDepartments.push(department);
        break; // one match per department is enough
      }
    }
  }

  /* ---- STEP 2: Unique departments only (same department can match multiple keywords) ---- */

  const uniqueDepartments = [...new Set(matchedDepartments)];

  /* ---- STEP 3: Decision ---- */

  // One department (one keyword or multiple keywords of same department) → assign directly
  if (uniqueDepartments.length === 1) {
    return {
      department: uniqueDepartments[0],
      problem_type: extractProblemType(description)
    };
  }

  // Zero or multiple different departments → Gemini analyzes and picks one
  return await classifyWithGemini(description, uniqueDepartments);
}

/* ===================== GEMINI FALLBACK ===================== */
/*
  candidateDepartments: when multiple keywords match, pass those departments so Gemini
  picks only among them. When no keywords match, pass empty and we use full DEPARTMENTS list.
*/

async function classifyWithGemini(description, candidateDepartments = []) {
  const apiKey = process.env.GEMINI_API_KEY || process.env.GEMINI_KEY;

  if (!apiKey) {
    return fallbackDepartment(candidateDepartments);
  }

  const allowedList = candidateDepartments.length > 0 ? candidateDepartments : DEPARTMENTS;

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const modelId = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
    const model = genAI.getGenerativeModel({ model: modelId });

    const prompt = `
You are a civic complaint router. You will receive a complaint description. Your job is to understand the context and select the ONE department that is primarily responsible for resolving it.

Department responsibilities (understand the theme, not just keywords):
- GHMC Sanitation: Solid waste, garbage collection, dustbins, sweeping, litter, debris from waste.
- GHMC Road and Engineering: Roads, potholes, footpaths, pavements, road repair, road restoration, manholes (structural), anything where the road surface or road work is the main issue.
- HMWSSB: Water supply, drainage, sewers, drains, sewage, stagnant water, pipe leaks, water logging, foul smell or issues caused by drains/sewage/water.
- TSSPDCL: Electricity, street lights, power cuts, transformers, cables, poles, meters, electrical hazards.
- GHMC Town Planning: Illegal or unauthorized construction, encroachment, demolition, building violations.
- GHMC Public Health / Entomology: Mosquitoes, vector control, dengue, malaria, pests, stray animals, fogging.

Instructions:
- Read the complaint and identify the primary issue (root cause). If several things are mentioned, choose the department that owns the main problem.
- Reply with exactly one department from the list below. Use the department name exactly as written.

Allowed departments (choose exactly one):
${allowedList.join('\n')}

Complaint description:
"${description}"

Respond with ONLY a JSON object, no other text:
{"department": "<exact department name from the list>", "problem_type": "<short category 1-3 words>"}
`;

    const result = await model.generateContent(prompt);
    const responseText = (result.response && result.response.text()) || '';

    const jsonMatch = responseText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('Invalid Gemini response: no JSON found. Raw: ' + responseText.slice(0, 200));
    }

    const parsed = JSON.parse(jsonMatch[0]);
    const dept = (parsed.department && String(parsed.department).trim()) || '';

    const matched = matchDepartment(dept, allowedList);
    if (!matched) {
      throw new Error('Department not in allowed list: "' + dept + '". Allowed: ' + allowedList.join(', '));
    }

    return {
      department: matched,
      problem_type: (parsed.problem_type && String(parsed.problem_type).trim()) || 'General'
    };
  } catch (error) {
    console.error('[aiClassification] Gemini error:', error.message);
    return fallbackDepartment(candidateDepartments);
  }
}

function matchDepartment(given, allowedList) {
  const n = (given || '').trim().toLowerCase();
  if (!n) return null;
  return allowedList.find((d) => d.trim().toLowerCase() === n) || null;
}

function fallbackDepartment(candidateDepartments) {
  if (Array.isArray(candidateDepartments) && candidateDepartments.length > 0) {
    return { department: candidateDepartments[0], problem_type: 'General' };
  }
  return { department: 'GHMC Sanitation', problem_type: 'General' };
}

/* ===================== PROBLEM TYPE EXTRACTION ===================== */

function extractProblemType(description) {
  const text = description.toLowerCase();

  if (text.includes('pothole')) return 'Pothole';
  if (text.includes('garbage')) return 'Waste';
  if (text.includes('sewer') || text.includes('drainage')) return 'Sewerage';
  if (text.includes('water') || text.includes('leak')) return 'Water Supply';
  if (text.includes('street light') || text.includes('electric')) return 'Electrical';
  if (text.includes('mosquito')) return 'Vector Control';

  return 'General';
}

/* ===================== AUTO TAG GENERATION ===================== */

function generateAutoTags(description, department) {
  const tags = new Set();
  const text = description.toLowerCase();

  const departmentTags = {
    'GHMC Sanitation': 'Sanitation',
    'GHMC Road and Engineering': 'Road',
    'HMWSSB': 'Water',
    'TSSPDCL': 'Electricity',
    'GHMC Town Planning': 'Town Planning',
    'GHMC Public Health / Entomology': 'Public Health'
  };

  if (departmentTags[department]) {
    tags.add(departmentTags[department]);
  }

  if (text.includes('pothole')) tags.add('Road');
  if (text.includes('garbage')) tags.add('Sanitation');
  if (text.includes('water') || text.includes('sewer')) tags.add('Water');
  if (text.includes('electric') || text.includes('light')) tags.add('Electricity');
  if (text.includes('mosquito')) tags.add('Public Health');

  return Array.from(tags);
}

module.exports = {
  classifyDepartment,
  generateAutoTags,
  DEPARTMENTS
};
