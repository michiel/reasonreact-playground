FROM node:alpine as builder
RUN apk update && apk add --no-cache make git build-base gcc
RUN apk add python python-dev py-pip
WORKDIR /app
COPY package.json bsconfig.json webpack.config.js /app/
COPY src/ /app/src/
RUN cd /app && npm set progress=false && npm install
RUN cd /app && npm run build
RUN cd /app && npm run webpack:production

FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
## From 'builder' copy website to default nginx public folder
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/build /www
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
