import * as restify from 'restify';
import * as jwt from 'jsonwebtoken';
import * as corsMiddleware from 'restify-cors-middleware';
import logger from './logger';
import routes from './routes';

const secretKey = process.env.SECRET_KEY || 'secretKey';

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

server.use((req: restify.Request, res: restify.Response, next: restify.Next) => {
  const accessToken = req.headers['authorization'];
  try {
    jwt.verify(accessToken, secretKey);
    return next();
  } catch (e) {
    logger.error(e);
    res.send(403, 'Not Authorized');
    return next(false);
  }
});

async function init() {
  server.post('/getProduct', routes.getProduct);
  server.post('/listProducts', routes.listProducts);
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