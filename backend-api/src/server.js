require('dotenv').config();
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('../swagger.json');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api-docs', swaggerUi.serve, (req, res, next) => {
  const host = req.get('host');
  const protocol = req.get('x-forwarded-proto') || req.protocol;
  const doc = { ...swaggerDocument, servers: [{ url: `${protocol}://${host}`, description: 'Server' }] };
  swaggerUi.setup(doc)(req, res, next);
});
app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

app.use('/api', require('./routes/api'));

app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(err.statusCode || err.status || 500).json({
    success: false,
    error: { message: err.message || 'Internal Server Error' }
  });
});

app.listen(PORT, () => {
  console.log(`EcoPoint API running on port ${PORT}`);
});
