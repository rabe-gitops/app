# BUILD STAGE
FROM node:13.8.0-alpine AS build-stage
WORKDIR /usr/local/app/
COPY package.json ./
COPY yarn.lock ./
COPY src/ ./src/
COPY public/ ./public/
RUN yarn install --frozen-lockfile
RUN yarn run build

# PRODUCTION STAGE
FROM nginx:1.17.8-alpine
COPY --from=build-stage /usr/local/app/dist /usr/share/nginx/html
RUN sed -i 's/listen.*;/listen 8080;/g' /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

