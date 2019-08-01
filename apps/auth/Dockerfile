FROM node:10.16

WORKDIR /app

ENV PG_PORT=5432
ENV CLIENT_ID='clientId'
ENV SECRET_KEY='secretKey'
ENV PORT=8001

COPY . /app
RUN npm install --no-package-lock
RUN npm run build

EXPOSE 8001
CMD [ "npm", "start" ]