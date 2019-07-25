import * as restify from 'restify';
import * as jwt from 'jsonwebtoken';
import * as corsMiddleware from 'restify-cors-middleware';
import { Token } from './interface';
import logger from './logger';
import routes from './routes';
import config from './config';

const CLIENT_ID = config.CLIENT_ID;
const SECRET_KEY = config.SECRET_KEY;

const cors = corsMiddleware({
  origins: ['*'],
  allowHeaders: ['authorization'],
  exposeHeaders: [],
});

const server: restify.Server = restify.createServer();
server.pre(restify.plugins.pre.sanitizePath());
server.pre(cors.preflight);

server.use(restify.plugins.queryParser());
server.use(restify.plugins.bodyParser());
server.use(restify.plugins.gzipResponse());
server.use(cors.actual);

const checkAuthority = (req: restify.Request, res: restify.Response, next: restify.Next) => {
  const accessToken = req.headers['authorization'];
  if (!accessToken) {
    res.send(403, 'Not Authorized');
    return next(false);
  }

  try {
    const decoded: Token = <Token>jwt.verify(accessToken, SECRET_KEY);
    if (decoded.clientId !== CLIENT_ID) {
      throw new Error('CLIENT_ID does not match');
    }
    req.body = Object.assign({_session: decoded}, req.body);
    // TODO: should check email using grpc
    return next();
  } catch (e) {
    logger.error(e.stack);
    res.send(403, 'Not Verified');
    return next(false);
  }
};

async function init() {
  server.use(checkAuthority);
  server.post('/alarm', routes.setAlarm);
  server.del('/alarm', routes.deleteAlarm);
  server.get('/product', routes.getProduct);
  server.post('/products', routes.listProducts);
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