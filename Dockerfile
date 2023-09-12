FROM node:alpine AS build
RUN npm install -g @angular/cli@latest
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN ng build

# Stage 2: Serve the built artifacts using Nginx
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist/* /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

