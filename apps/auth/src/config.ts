export default {
  PG_HOST: process.env.PG_HOST || 'authdb.cggrl7pirkvu.ap-northeast-2.rds.amazonaws.com',
  PG_PORT: process.env.PG_PORT || 5432,
  CLIENT_ID: process.env.CLIENT_ID || 'clientId',
  SECRET_KEY: process.env.SECRET_KEY || 'secretKey',
}