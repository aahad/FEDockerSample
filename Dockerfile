FROM node:12.7-alpine AS builder

WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
RUN node_modules/.bin/ng build
 
### STAGE 2: Run ###
FROM nginx:1.17.1-alpine
EXPOSE 80
ARG PROJECT=myDockerapp

## Copy our default nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From ‘builder’ stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /usr/src/app/dist/${PROJECT} /usr/share/nginx/html
COPY nginx/40x.html /usr/share/nginx/html
COPY nginx/50x.html /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]