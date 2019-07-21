import * as restify from 'restify';
import * as corsMiddleware from 'restify-cors-middleware';
import logger from './logger';
import routes from './routes';

const cors = corsMiddleware({
  origins: ['*'],
  allowHeaders: ['Authorization'],
  exposeHeaders: [],
});

const server: restify.Server = restify.createServer();
server.pre(restify.plugins.pre.sanitizePath());
server.pre(cors.preflight);

server.use(restify.plugins.queryParser());
server.use(restify.plugins.bodyParser());
server.use(restify.plugins.gzipResponse());
server.use(cors.actual);

async function init() {
  server.post('/graphql', routes.graphql);
}

async function main() {
  await init();
  const PORT = process.env.PORT || 3000;
  await server.listen(PORT);
  logger.info(`Server Started on ${PORT}`);
}

main().catch((e) => {
  logger.error(e);
  throw e;
});