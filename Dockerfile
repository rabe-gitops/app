# BUILD STAGE
FROM node:14.4-alpine AS build-stage
COPY . /usr/local/app/
WORKDIR /usr/local/app/
RUN yarn install --frozen-lockfile --no-cache
RUN yarn run build
RUN yarn cache clean

# PRODUCTION STAGE
FROM nginx:1.19-alpine
COPY --from=build-stage /usr/local/app/dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

