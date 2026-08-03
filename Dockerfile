# STAGE 1 - Build
FROM node:lts-alpine AS build-stage

WORKDIR /app

COPY app/package.json ./

RUN npm install

COPY app/ .

RUN npm run build

# STAGE 2
FROM nginx:stable-alpine AS production

COPY --from=build-stage /app/dist /usr/share/nginx/html

COPY app/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]