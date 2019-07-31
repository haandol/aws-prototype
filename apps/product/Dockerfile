FROM node:10.16

WORKDIR /app

ENV CLIENT_ID='clientId'
ENV SECRET_KEY='secretKey'
ENV PORT=8000

COPY . /app

RUN npm i --no-package-lock

EXPOSE 8000
CMD [ "npm", "start" ]