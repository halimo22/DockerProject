# Three-Tier Application with Docker

## Overview
This project sets up a three-tier application using Docker with the following architecture:

1. **Backend** - Built using a multi-stage Dockerfile.
2. **Database** - Uses credentials stored on the host machine.
3. **Proxy** - Runs on HTTPS with configuration files stored on the host machine.

Each container operates in a separate network, and the entire project can be managed with a single command.

---
## Prerequisites
Ensure you have the following installed:

- Docker
- Docker Compose

---
## Project Structure
```
project-directory/
│── backend/                # Backend application files
│── proxy/                  # Proxy server configuration
│── docker-compose.yml      # Docker Compose file
│── .env                    # Environment variables
│── README.md               # Project documentation
```

---
## Configuration
### Environment Variables
Create a `.env` file at the root of the project with the following:
```ini
DB_USER=<your_db_username>
DB_PASSWORD=<your_db_password>
DB_NAME=<your_db_name>
```

Ensure that `.env` is included in `.gitignore` to protect sensitive information.

### Backend Dockerfile (Multi-Stage)
Located in `backend/Dockerfile`:
```dockerfile
# Stage 1: Build Stage
FROM node:18 as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Run Stage
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app .
CMD ["npm", "start"]
```

### Proxy Configuration
Ensure the proxy server runs on HTTPS. Place your proxy configuration files inside `proxy/`. Example Nginx configuration (`proxy/nginx.conf`):
```nginx
server {
    listen 443 ssl;
    server_name example.com;
    ssl_certificate /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    location / {
        proxy_pass http://backend:3000;
    }
}
```

Ensure SSL certificates are placed in `/etc/nginx/certs/` on your host machine.

---
## Networking Setup
Each service runs in its own network:
- `backend-network`
- `database-network`
- `proxy-network`

---
## Docker Compose File
Located in `docker-compose.yml`:
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    networks:
      - backend-network
    env_file:
      - .env

  database:
    image: postgres:latest
    networks:
      - database-network
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - pg_data:/var/lib/postgresql/data

  proxy:
    image: nginx:latest
    networks:
      - proxy-network
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/nginx/certs:/etc/nginx/certs:ro
    ports:
      - "443:443"

networks:
  backend-network:
  database-network:
  proxy-network:

volumes:
  pg_data:
```

---
## Running the Project
Start all services with:
```sh
docker-compose up -d
```

Stop all services with:
```sh
docker-compose down
```

---
## Notes
- Ensure your database credentials are correctly set in the `.env` file.
- Place valid SSL certificates in `/etc/nginx/certs/`.
- Each container runs in its dedicated network for security and isolation.

This setup ensures modularity, security, and maintainability while adhering to Docker best practices.

