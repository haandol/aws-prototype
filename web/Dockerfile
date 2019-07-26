FROM node:10.16

WORKDIR /app

ENV AUTH_URL=''
ENV PRODUCT_URL=''

COPY . /app

RUN npm i --no-package-lock
RUN npm run build

EXPOSE 3000
CMD [ "npm", "start" ]