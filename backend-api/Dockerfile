FROM node:22-slim
WORKDIR /app
COPY node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "src/server.js"]
