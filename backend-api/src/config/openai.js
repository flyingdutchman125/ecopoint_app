require('dotenv').config();
const OpenAI = require('openai');

const apiKey = process.env.OPENAI_API_KEY;
const baseURL = process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1';
const model = process.env.OPENAI_MODEL || 'gpt-4-vision-preview';

if (!apiKey) {
  throw new Error('Missing OPENAI_API_KEY in .env');
}

const openai = new OpenAI({
  apiKey,
  baseURL
});

module.exports = {
  openai,
  model
};
