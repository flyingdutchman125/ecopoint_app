const cheerio = require('cheerio');
const supabase = require('../config/supabase');

const BSI_URL = 'https://banksampahindonesia.com/daftar-harga/';

async function scrapeBSIPrices() {
  try {
    console.log(`Fetching BSI waste prices from: ${BSI_URL}`);
    
    const response = await fetch(BSI_URL, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const html = await response.text();
    const $ = cheerio.load(html);

    const prices = [];
    const itemMap = {
      'kardus': 'Cardboard',
      'duplek': 'Cardboard',
      'botol pet': 'PET Plastic',
      'plastik pet': 'PET Plastic',
      'pet bening': 'PET Plastic',
      'pet biru': 'PET Plastic',
      'pet warna': 'PET Plastic',
      'kaleng': 'Metal',
      'alma kaleng': 'Metal',
      'aluminium': 'Metal',
      'aluminum': 'Metal',
      'besi': 'Metal',
      'minyak jelantah': 'Cooking Oil',
      'minyak goreng bekas': 'Cooking Oil',
      'jelantah': 'Cooking Oil'
    };

    $('table').each((tableIndex, table) => {
      $(table).find('tr').each((rowIndex, row) => {
        const cells = $(row).find('td');
        
        if (cells.length >= 4) {
          const itemText = $(cells[1]).text().trim().toLowerCase();
          const priceText = $(cells[3]).text().trim();
          
          const priceMatch = priceText.match(/[\d.,]+/);
          if (priceMatch) {
            const price = parseFloat(priceMatch[0].replace(/\./g, '').replace(',', '.'));
            
            for (const [keyword, standardName] of Object.entries(itemMap)) {
              if (itemText.includes(keyword)) {
                prices.push({
                  item_name: standardName,
                  price: price,
                  source_text: itemText
                });
                break;
              }
            }
          }
        }
      });
    });

    if (prices.length === 0) {
      console.warn('No prices found during scraping. HTML structure may have changed.');
      return {
        success: false,
        message: 'No prices extracted from website',
        count: 0
      };
    }

    const aggregatedPrices = {};
    prices.forEach(item => {
      if (!aggregatedPrices[item.item_name] || aggregatedPrices[item.item_name] < item.price) {
        aggregatedPrices[item.item_name] = item.price;
      }
    });

    const upsertPromises = Object.entries(aggregatedPrices).map(async ([itemName, price]) => {
      const { error } = await supabase
        .from('catalog_prices')
        .upsert(
          {
            item_name: itemName,
            current_price: price,
            last_updated: new Date().toISOString()
          },
          { onConflict: 'item_name' }
        );

      if (error) {
        console.error(`Error upserting ${itemName}:`, error);
        throw error;
      }

      return { itemName, price };
    });

    await Promise.all(upsertPromises);

    console.log(`Successfully scraped and updated ${Object.keys(aggregatedPrices).length} prices`);

    return {
      success: true,
      message: 'Prices updated successfully',
      count: Object.keys(aggregatedPrices).length,
      prices: aggregatedPrices
    };

  } catch (error) {
    console.error('Scraper Service Error:', error);
    throw new Error(`Failed to scrape BSI prices: ${error.message}`);
  }
}

async function getCatalogPrices() {
  try {
    const { data, error } = await supabase
      .from('catalog_prices')
      .select('*')
      .order('item_name', { ascending: true });

    if (error) throw error;

    return data;
  } catch (error) {
    console.error('Get Catalog Prices Error:', error);
    throw new Error(`Failed to get catalog prices: ${error.message}`);
  }
}

module.exports = {
  scrapeBSIPrices,
  getCatalogPrices
};
