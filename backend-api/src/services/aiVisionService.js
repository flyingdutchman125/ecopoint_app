const { openai, model } = require('../config/openai');

async function analyzeWasteImage(photoUrl) {
  try {
    if (!photoUrl) {
      throw new Error('Photo URL is required');
    }

    const prompt = `Analyze this image carefully. Does it contain recyclable waste specifically from these categories: cardboard, PET plastic bottles, metal/aluminum cans, or used cooking oil containers?

Reply ONLY with valid JSON in this exact format:
{
  "isValid": true or false,
  "detectedType": "cardboard" or "PET plastic" or "metal" or "cooking oil" or "unknown",
  "estimatedConfidence": number between 0 and 1,
  "reasoning": "brief explanation"
}

Be strict: only approve clear, identifiable recyclable waste from the categories listed.`;

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
      throw new Error('No response from AI vision model');
    }

    let result;
    try {
      result = JSON.parse(content);
    } catch (parseError) {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        result = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('Failed to parse AI response as JSON');
      }
    }

    return {
      isValid: Boolean(result.isValid),
      detectedType: result.detectedType || 'unknown',
      estimatedConfidence: Number(result.estimatedConfidence) || 0,
      reasoning: result.reasoning || 'No reasoning provided'
    };

  } catch (error) {
    console.error('AI Vision Service Error:', error);
    throw new Error(`AI Vision analysis failed: ${error.message}`);
  }
}

module.exports = {
  analyzeWasteImage
};
