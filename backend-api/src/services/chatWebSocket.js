const { WebSocketServer } = require('ws');

let wss = null;
const subscriptions = new Map(); // orderId -> Set of ws clients

function initWebSocket(server) {
  wss = new WebSocketServer({ server });

  wss.on('connection', (ws, req) => {
    ws.subscribedOrders = new Set();

    ws.on('message', (raw) => {
      try {
        const data = JSON.parse(raw.toString());
        if (data.type === 'subscribe' && data.orderId) {
          const orderId = String(data.orderId);
          ws.subscribedOrders.add(orderId);
          if (!subscriptions.has(orderId)) {
            subscriptions.set(orderId, new Set());
          }
          subscriptions.get(orderId).add(ws);
          ws.send(JSON.stringify({ type: 'subscribed', orderId }));
        } else if (data.type === 'unsubscribe' && data.orderId) {
          const orderId = String(data.orderId);
          ws.subscribedOrders.delete(orderId);
          if (subscriptions.has(orderId)) {
            subscriptions.get(orderId).delete(ws);
          }
          ws.send(JSON.stringify({ type: 'unsubscribed', orderId }));
        } else if (data.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong' }));
        }
      } catch (e) {
        console.error('WebSocket message parse error:', e.message);
      }
    });

    ws.on('close', () => {
      for (const orderId of ws.subscribedOrders) {
        if (subscriptions.has(orderId)) {
          subscriptions.get(orderId).delete(ws);
        }
      }
    });
  });

  console.log('WebSocket server initialized for real-time 2-way chat');
}

function broadcastMessage(orderId, messagePayload) {
  const orderStr = String(orderId);
  const targetClients = subscriptions.get(orderStr);
  if (!targetClients) return;

  const payload = JSON.stringify({
    type: 'new_message',
    orderId: orderStr,
    data: messagePayload
  });

  for (const client of targetClients) {
    if (client.readyState === 1) { // 1 = OPEN
      client.send(payload);
    }
  }
}

module.exports = {
  initWebSocket,
  broadcastMessage
};
