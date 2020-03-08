# BUILD STAGE
FROM node:13.8.0-alpine AS build-stage
COPY . /usr/local/app/
WORKDIR /usr/local/app/
RUN yarn install --frozen-lockfile
RUN yarn run build

# PRODUCTION STAGE
FROM nginx:1.17.8-alpine
COPY --from=build-stage /usr/local/app/dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

