# STAGE 1 - Build
FROM node:lts-alpine AS build-stage
WORKDIR /app
COPY app/package.json ./
RUN npm install -g pnpm@8 && pnpm i --no-frozen-lockfile
COPY app/ .
RUN pnpm build

# STAGE 2 - Production
FROM nginx:stable-alpine AS production
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY app/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]