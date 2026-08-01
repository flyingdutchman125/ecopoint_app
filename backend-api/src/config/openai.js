require('dotenv').config();

const apiKey = process.env.OPENAI_API_KEY;
const baseURL = process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1';
const model = process.env.OPENAI_MODEL || 'gpt-4-vision-preview';

if (!apiKey) {
  console.warn('⚠️  Missing OPENAI_API_KEY in environment. AI vision features will use fallback analysis.');
  module.exports = { openai: null, model: null };
} else {
  const OpenAI = require('openai');
  const openai = new OpenAI({ apiKey, baseURL });
  module.exports = { openai, model };
}
