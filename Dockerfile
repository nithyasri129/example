FROM node:18-alpine

# Create app directory
WORKDIR /app/backend

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY backend/package*.json ./
RUN npm install --production

# Copy backend source
COPY backend/ ./

# Copy frontend into expected location so server can serve static files
COPY frontend/ ../frontend/

# Create data directory for SQLite DB
RUN mkdir -p /app/backend/data

# Expose port (server listens on 5000 by default)
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
