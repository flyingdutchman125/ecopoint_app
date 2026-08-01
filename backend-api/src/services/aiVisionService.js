let openai, model;

try {
  const openaiConfig = require('../config/openai');
  openai = openaiConfig.openai;
  model = openaiConfig.model;
} catch (e) {
  console.warn('OpenAI not configured, using fallback AI analysis:', e.message);
  openai = null;
  model = null;
}

// Fallback category detection based on keywords
function fallbackAnalysis(photoUrl) {
  const url = (photoUrl || '').toLowerCase();
  
  const categoryKeywords = {
    'PET Plastic': ['plastic', 'pet', 'bottle', 'botol', 'plastik'],
    'HDPE Plastic': ['hdpe', 'jerrycan', 'jerigen'],
    'PP Plastic': ['pp', 'polypropylene'],
    'Cardboard': ['cardboard', 'karton', 'kardus', 'paper', 'kertas'],
    'Metal/Aluminum': ['metal', 'aluminum', 'aluminium', 'kaleng', 'can'],
    'Iron/Steel': ['iron', 'steel', 'besi'],
    'Copper': ['copper', 'tembaga'],
    'Glass': ['glass', 'kaca', 'botol_kaca'],
    'Electronic Waste': ['electronic', 'elektronik', 'ewaste', 'gadget'],
    'Battery': ['battery', 'baterai', 'aki'],
    'Cooking Oil': ['oil', 'minyak', 'jelantah', 'cooking'],
    'Textile/Fabric': ['textile', 'fabric', 'kain', 'baju'],
    'Rubber/Tire': ['rubber', 'tire', 'ban', 'karet'],
  };

  for (const [category, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(kw => url.includes(kw))) {
      return {
        isValid: true,
        category: category,
        detectedType: category,
        estimatedConfidence: 0.7,
        reasoning: `Detected from image context (fallback analysis)`
      };
    }
  }

  return {
    isValid: true,
    category: 'Mixed Waste',
    detectedType: 'Mixed Waste',
    estimatedConfidence: 0.5,
    reasoning: 'AI vision service unavailable. Default category assigned - you can change it manually.'
  };
}

async function analyzeWasteImage(photoUrl) {
  try {
    if (!photoUrl) {
      throw new Error('Photo URL is required');
    }

    // If OpenAI is not configured, use fallback
    if (!openai) {
      console.log('Using fallback AI analysis (OpenAI not configured)');
      return fallbackAnalysis(photoUrl);
    }

    const prompt = `Analyze this image carefully. Does it contain recyclable waste? Identify the type from these categories: PET Plastic, HDPE Plastic, PP Plastic, Cardboard, Paper, Metal/Aluminum, Iron/Steel, Copper, Glass, Electronic Waste, Battery, Cooking Oil, Textile/Fabric, Rubber/Tire, Wood, Organic Waste, Mixed Waste, Other.

Reply ONLY with valid JSON in this exact format:
{
  "isValid": true or false,
  "category": "one of the categories above",
  "detectedType": "one of the categories above",
  "estimatedConfidence": number between 0 and 1,
  "reasoning": "brief explanation"
}

Be helpful: assign the closest matching category even if uncertain.`;

    const response = await openai.chat.completions.create({
      model: model,
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            {
              type: 'image_url',
              image_url: {
                url: photoUrl
              }
            }
          ]
        }
      ],
      max_tokens: 300,
      temperature: 0.3,
      stream: false
    });

    const content = response.choices[0]?.message?.content;
    
    if (!content) {
      console.warn('No response from AI, using fallback');
      return fallbackAnalysis(photoUrl);
    }

    let result;
    try {
      result = JSON.parse(content);
    } catch (parseError) {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        result = JSON.parse(jsonMatch[0]);
      } else {
        console.warn('Failed to parse AI response, using fallback');
        return fallbackAnalysis(photoUrl);
      }
    }

    return {
      isValid: Boolean(result.isValid),
      category: result.category || result.detectedType || 'Mixed Waste',
      detectedType: result.detectedType || result.category || 'Mixed Waste',
      estimatedConfidence: Number(result.estimatedConfidence) || 0,
      reasoning: result.reasoning || 'No reasoning provided'
    };

  } catch (error) {
    console.error('AI Vision Service Error:', error.message);
    // Return fallback instead of throwing - never crash the user experience
    return fallbackAnalysis(photoUrl);
  }
}

module.exports = {
  analyzeWasteImage
};
