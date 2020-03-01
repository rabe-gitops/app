FROM node:13.8.0-alpine
EXPOSE 8080
WORKDIR /usr/local/app/
COPY package.json ./
COPY yarn.lock ./
COPY src/ ./src/
COPY public/ ./public/
RUN yarn install --frozen-lockfile
RUN yarn run build
CMD ["yarn", "run", "serve"]
