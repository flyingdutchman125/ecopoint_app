const OSRM_BASE_URL = 'http://router.project-osrm.org';

async function getRoute(collectorLng, collectorLat, userLng, userLat) {
  try {
    const url = `${OSRM_BASE_URL}/route/v1/driving/${collectorLng},${collectorLat};${userLng},${userLat}?overview=full&geometries=geojson&steps=true`;

    console.log(`Fetching OSRM route: ${url}`);

    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`OSRM API error! status: ${response.status}`);
    }

    const data = await response.json();

    if (data.code !== 'Ok') {
      throw new Error(`OSRM routing failed: ${data.message || 'Unknown error'}`);
    }

    const route = data.routes[0];

    return {
      distance: route.distance,
      duration: route.duration,
      geometry: route.geometry,
      steps: route.legs[0]?.steps || []
    };

  } catch (error) {
    console.error('OSRM Service Error:', error);
    throw new Error(`Failed to get route: ${error.message}`);
  }
}

async function getETA(collectorLng, collectorLat, userLng, userLat) {
  try {
    const route = await getRoute(collectorLng, collectorLat, userLng, userLat);
    
    return {
      distance_meters: route.distance,
      duration_seconds: route.duration,
      eta_minutes: Math.ceil(route.duration / 60)
    };

  } catch (error) {
    console.error('OSRM ETA Error:', error);
    throw new Error(`Failed to calculate ETA: ${error.message}`);
  }
}

module.exports = {
  getRoute,
  getETA
};
