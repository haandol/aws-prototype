FROM node:10.16

WORKDIR /app

ARG RDS

ENV PG_HOST=${RDS}
ENV PG_PORT=5432
ENV CLIENT_ID='clientId'
ENV SECRET_KEY='secretKey'
ENV PORT=8001

COPY . /app

RUN npm i --no-package-lock

EXPOSE 8000
CMD [ "npm", "start" ]