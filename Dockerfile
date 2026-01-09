FROM node:22-alpine AS frontend-builder

WORKDIR /build

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build:frontend

FROM golang:1.22-alpine AS backend-builder

WORKDIR /build

COPY backend-go/go.mod .
COPY backend-go/main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

FROM scratch

WORKDIR /app

COPY --from=backend-builder /build/server .
COPY --from=frontend-builder /build/dist ./dist

ENV PORT=8081
ENV DIST_PATH=/app/dist

EXPOSE 8081

ENTRYPOINT ["/app/server"]
