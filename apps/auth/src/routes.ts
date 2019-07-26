import * as restify from 'restify';
import Service from './service';
import logger from './logger';
import { Account, UserToken } from './interface';

const service: Service = new Service();

function responder(handler: (req: restify.Request) => Promise<any>) {
  return async (req: restify.Request, res: restify.Response, next: restify.Next) => {
    try {
      const data = await handler(req);
      res.send(200, { data });
      return next()
    } catch (e) {
      logger.error(e.stack);
      res.send(503, {
        err: e.toString(),
        req: req.body || {},
      });
      return next(false);
    }
  }
}

export default {
  healthcheck: responder(async (req): Promise<void> => {
    logger.debug(`[Healthcheck] ${JSON.stringify(req.query)}`);
    return;
  }),
  signin: responder(async (req): Promise<UserToken> => {
    logger.debug(`[Signin] ${JSON.stringify(req.body)}`);
    if (!req.body) {
      throw new Error('Empty Payload');
    }
    if (!req.body.email || !req.body.password) {
      throw new Error('EMAIL_OR_PASSWORD_IS_MISSING');
    }
    return await service.getTokenUsingPassword(req.body.email,
                                               req.body.password);
  }),
  signout: responder(async (req): Promise<void> => {
    logger.debug(`[Signout] ${JSON.stringify(req.body)}`);
    return;
  }),
  getAccountByEmail: responder(async (req): Promise<Account | null> => {
    logger.debug(`[GetAccount] ${JSON.stringify(req.body)}`);
    const email: string = req.body._session.email;
    return await service.getAccountByEmail(email);
  }),
}