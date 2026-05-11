# Stage 1 — Install dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install --production

# Stage 2 — Run the app
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "src/index.js"]
