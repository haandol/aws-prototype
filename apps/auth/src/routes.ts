import * as restify from 'restify';
import Service from './service';
import logger from './logger';

const clientId = process.env.CLIENT_ID || 'clientId';
const secretKey = process.env.SECRET_KEY || 'secretKey';

const service: Service = new Service(clientId, secretKey);

function responder(handler: (req: restify.Request) => Promise<any>) {
  return async (req: restify.Request, res: restify.Response, next: restify.Next) => {
    try {
      const data = await handler(req);
      res.send(200, { data });
      return next()
    } catch (e) {
      res.send(503, {
        err: e.toString(),
        req: req.body || {},
      });
      return next(false);
    }
  }
}

export default {
  signin: responder(async (req) => {
    logger.debug(`[Signin] payload: ${JSON.stringify(req.body)}`);
    if (!req.body) {
      throw new Error('Empty Payload');
    }
    if (!req.body.email || !req.body.password) {
      throw new Error('EMAIL_OR_PASSWORD_IS_MISSING');
    }

    return await service.getTokenUsingPassword(req.body.email, req.body.password);
  }),
  signout: responder(async (req) => {
    logger.debug(`[Signout] payload: ${JSON.stringify(req.body)}`);
    return req.body;
  }),
}