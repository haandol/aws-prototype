FROM node:10.16

WORKDIR /app

ENV CLIENT_ID='clientId'
ENV SECRET_KEY='secretKey'
ENV PORT=8000

COPY . /app
RUN npm install
RUN npm run build

EXPOSE 8000
CMD [ "npm", "start" ]