const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const DEPARTMENTS = [
  'GHMC Sanitation',
  'GHMC Road & Engineering',
  'HMWSSB (Water Board)',
  'TSSPDCL (Electricity)',
  'GHMC Town Planning',
  'GHMC Public Health / Entomology'
];

const KEYWORDS = {
  'GHMC Sanitation': [
    'garbage', 'dustbin', 'trash', 'bins', 'smell', 'dumping', 'waste', 
    'debris', 'cleaning', 'sweep', 'sanitation', 'refuse', 'overflowing', 
    'Swachh Bharat', 'cleaning staff'
  ],
  'GHMC Road & Engineering': [
    'road', 'pothole', 'street', 'damaged', 'construction', 'repair', 
    'cracking', 'footpath', 'pavement', 'resurface', 'speed breaker', 
    'culvert', 'manhole', 'dig'
  ],
  'HMWSSB (Water Board)': [
    'water', 'leak', 'drainage', 'sewer', 'overflow', 'pipeline', 
    'contamination', 'sewage', 'dirty water', 'tap', 'borewell', 
    'pipe burst', 'stagnation'
  ],
  'TSSPDCL (Electricity)': [
    'light', 'street light', 'pole', 'transformer', 'electric', 'cable', 
    'wiring', 'spark', 'shock', 'power cut', 'fuse', 'bulb', 'dark', 'meter'
  ],
  'GHMC Town Planning': [
    'illegal construction', 'encroachment', 'demolition', 'unauthorized', 
    'building', 'structure', 'setback', 'boundary', 'commercial misuse', 
    'banner', 'hoarding', 'advertisement'
  ],
  'GHMC Public Health / Entomology': [
    'mosquito', 'dengue', 'malaria', 'fever', 'stray dog', 'rat', 'pest', 
    'insect', 'fogging', 'vaccination', 'animal cruelty', 'epidemic'
  ]
};

/**
 * Classify department using keyword matching first, then Gemini AI
 */
async function classifyDepartment(description) {
  if (!description || typeof description !== 'string') {
    return { department: 'GHMC Sanitation', problem_type: 'General' };
  }

  const text = description.toLowerCase();
  const matchedDepartments = [];

  // Check keywords
  for (const [dept, keywords] of Object.entries(KEYWORDS)) {
    for (const keyword of keywords) {
      if (text.includes(keyword.toLowerCase())) {
        if (!matchedDepartments.includes(dept)) {
          matchedDepartments.push(dept);
        }
        break;
      }
    }
  }

  // If exactly one department matched, return it
  if (matchedDepartments.length === 1) {
    return { 
      department: matchedDepartments[0], 
      problem_type: extractProblemType(description, matchedDepartments[0])
    };
  }

  // If 0 or more than 1 matched, use Gemini
  if (matchedDepartments.length === 0 || matchedDepartments.length > 1) {
    return await classifyWithGemini(description, matchedDepartments);
  }

  // Fallback
  return { department: 'GHMC Sanitation', problem_type: 'General' };
}

/**
 * Use Gemini AI to classify department
 */
async function classifyWithGemini(description, matchedDepartments = []) {
  try {
    // Support both GEMINI_API_KEY and GEMINI_KEY
    const apiKey = process.env.GEMINI_API_KEY || process.env.GEMINI_KEY;
    if (!apiKey) {
      console.warn('⚠️  Gemini API key not found. Using fallback.');
      return { department: 'GHMC Sanitation', problem_type: 'General' };
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    const deptList = DEPARTMENTS.join(', ');
    const prompt = `Given this complaint description: "${description}"

Choose ONLY ONE department from this list: ${deptList}

Also provide a short problem_type category (1-3 words).

Respond in JSON format:
{
  "department": "exact department name from the list",
  "problem_type": "short category"
}

If the description doesn't clearly match any department, default to "GHMC Sanitation".`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Try to parse JSON from response
    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        if (DEPARTMENTS.includes(parsed.department)) {
          return {
            department: parsed.department,
            problem_type: parsed.problem_type || 'General'
          };
        }
      }
    } catch (e) {
      console.error('Failed to parse Gemini response:', e);
    }

    // Fallback
    return { department: 'GHMC Sanitation', problem_type: 'General' };
  } catch (error) {
    console.error('Gemini classification error:', error);
    return { department: 'GHMC Sanitation', problem_type: 'General' };
  }
}

function extractProblemType(description, department) {
  // Simple extraction based on keywords
  const text = description.toLowerCase();
  if (text.includes('pothole')) return 'Pothole';
  if (text.includes('garbage') || text.includes('trash')) return 'Waste Management';
  if (text.includes('water') || text.includes('leak')) return 'Water Issue';
  if (text.includes('light') || text.includes('electric')) return 'Electrical Issue';
  return 'General';
}

module.exports = { classifyDepartment, DEPARTMENTS };
