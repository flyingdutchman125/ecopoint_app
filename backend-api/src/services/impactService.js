const impactFactors = {
  'pet plastic': 1.5,
  'cardboard': 0.6,
  'metal': 2.3,
  'cooking oil': 1.1,
};

function estimateCarbonReduction(itemType, weight) {
  const normalizedType = String(itemType || '').trim().toLowerCase();
  const factor = Object.entries(impactFactors).find(([key]) => normalizedType.includes(key))?.[1] || 0.8;
  const value = parseFloat(weight) * factor;
  return parseFloat((value >= 0 ? value : 0).toFixed(2));
}

function getEcoTreeLevel(totalCarbonReduction) {
  if (totalCarbonReduction >= 25) return 'Eco Tree';
  if (totalCarbonReduction >= 10) return 'Eco Sprout';
  return 'Eco Seedling';
}

module.exports = {
  estimateCarbonReduction,
  getEcoTreeLevel
};
