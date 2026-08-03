require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('../swagger.json');
const chatWS = require('./services/chatWebSocket');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const path = require('path');
const fs = require('fs');
const uploadsPath = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(uploadsPath, { recursive: true });
}
app.use('/uploads', express.static(uploadsPath));

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

const server = http.createServer(app);
chatWS.initWebSocket(server);

const HOST = '0.0.0.0';
server.listen(PORT, HOST, () => {
  console.log(`EcoPoint API running on http://${HOST}:${PORT}`);
});
