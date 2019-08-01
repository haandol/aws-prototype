FROM node:10.16

WORKDIR /app

COPY . /app

RUN npm install --no-package-lock
RUN npm run build

EXPOSE 3000
CMD [ "npm", "start" ]