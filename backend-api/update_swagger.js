const fs = require('fs');

const swaggerPath = './swagger.json';
const swaggerDoc = JSON.parse(fs.readFileSync(swaggerPath, 'utf8'));

// New Paths to add
const newPaths = {
  "/api/forgot-password": {
    "post": {
      "tags": ["Auth"],
      "summary": "Request password reset",
      "requestBody": {
        "required": true,
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "email": { "type": "string", "example": "user@test.com" }
              }
            }
          }
        }
      },
      "responses": {
        "200": { "description": "Password reset instructions sent" }
      }
    }
  },
  "/api/profile": {
    "put": {
      "tags": ["User Profile"],
      "summary": "Update user profile",
      "security": [{ "bearerAuth": [] }],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "name": { "type": "string" },
                "phone": { "type": "string" },
                "avatar_url": { "type": "string" }
              }
            }
          }
        }
      },
      "responses": { "200": { "description": "Profile updated" } }
    }
  },
  "/api/addresses": {
    "get": {
      "tags": ["User Profile"],
      "summary": "Get user addresses",
      "security": [{ "bearerAuth": [] }],
      "responses": { "200": { "description": "List of addresses" } }
    },
    "post": {
      "tags": ["User Profile"],
      "summary": "Add new address",
      "security": [{ "bearerAuth": [] }],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "label": { "type": "string", "example": "Rumah" },
                "address": { "type": "string" },
                "latitude": { "type": "number" },
                "longitude": { "type": "number" },
                "is_primary": { "type": "boolean" }
              }
            }
          }
        }
      },
      "responses": { "201": { "description": "Address added" } }
    }
  },
  "/api/addresses/{id}": {
    "delete": {
      "tags": ["User Profile"],
      "summary": "Delete an address",
      "security": [{ "bearerAuth": [] }],
      "parameters": [
        { "name": "id", "in": "path", "required": true, "schema": { "type": "string" } }
      ],
      "responses": { "200": { "description": "Address deleted" } }
    }
  },
  "/api/wallet/topup": {
    "post": {
      "tags": ["Wallet"],
      "summary": "Request wallet top up",
      "security": [{ "bearerAuth": [] }],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "amount": { "type": "number", "example": 50000 },
                "payment_method": { "type": "string", "example": "bank_transfer" }
              }
            }
          }
        }
      },
      "responses": { "201": { "description": "Top up successful" } }
    }
  },
  "/api/wallet/withdraw": {
    "post": {
      "tags": ["Wallet"],
      "summary": "Request wallet withdrawal",
      "security": [{ "bearerAuth": [] }],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "amount": { "type": "number", "example": 50000 },
                "bank_name": { "type": "string", "example": "BCA" },
                "account_number": { "type": "string" }
              }
            }
          }
        }
      },
      "responses": { "201": { "description": "Withdrawal requested" } }
    }
  },
  "/api/order/{id}/messages": {
    "get": {
      "tags": ["Order Chat"],
      "summary": "Get chat messages for an order",
      "security": [{ "bearerAuth": [] }],
      "parameters": [
        { "name": "id", "in": "path", "required": true, "schema": { "type": "string" } }
      ],
      "responses": { "200": { "description": "List of messages" } }
    },
    "post": {
      "tags": ["Order Chat"],
      "summary": "Send a chat message",
      "security": [{ "bearerAuth": [] }],
      "parameters": [
        { "name": "id", "in": "path", "required": true, "schema": { "type": "string" } }
      ],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "message": { "type": "string" }
              }
            }
          }
        }
      },
      "responses": { "201": { "description": "Message sent" } }
    }
  },
  "/api/order/{id}/review": {
    "post": {
      "tags": ["Order Review"],
      "summary": "Add review and rating",
      "security": [{ "bearerAuth": [] }],
      "parameters": [
        { "name": "id", "in": "path", "required": true, "schema": { "type": "string" } }
      ],
      "requestBody": {
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "reviewee_id": { "type": "string" },
                "rating": { "type": "integer", "example": 5 },
                "comment": { "type": "string" }
              }
            }
          }
        }
      },
      "responses": { "201": { "description": "Review added" } }
    }
  }
};

// Merge paths
swaggerDoc.paths = { ...swaggerDoc.paths, ...newPaths };

// Add Tags if they don't exist
if (!swaggerDoc.tags) swaggerDoc.tags = [];
const existingTags = swaggerDoc.tags.map(t => t.name);
const tagsToAdd = ["User Profile", "Wallet", "Order Chat", "Order Review"];
tagsToAdd.forEach(t => {
  if (!existingTags.includes(t)) {
    swaggerDoc.tags.push({ name: t });
  }
});

fs.writeFileSync(swaggerPath, JSON.stringify(swaggerDoc, null, 2));
console.log('Successfully updated swagger.json');
