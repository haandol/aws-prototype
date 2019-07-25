export default {
  aws_project_region: 'ap-northeast-2',
  aws_appsync_graphqlEndpoint: process.env.AWS_APPSYNC_GRAPHQL_ENDPOINT || 'https://da25g5znkvgf5bolbdijdqj6p4.appsync-api.ap-northeast-2.amazonaws.com/graphql',
  aws_appsync_authenticationType: 'API_KEY',
  aws_appsync_apiKey: process.env.AWS_APPSYNC_APIKEY || 'da2-libpmlqtzvebbm6h7yazatd3zi',
  CLIENT_ID: process.env.CLIENT_ID || 'clientId',
  SECRET_KEY: process.env.SECRET_KEY || 'secretKey',
}
