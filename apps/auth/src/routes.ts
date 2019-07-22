import * as restify from 'restify';
import * as jwt from 'jsonwebtoken';
import { Token } from './interface';
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

function checkAuthority(req: restify.Request, res: restify.Response, next: restify.Next) {
  const accessToken = req.headers['authorization'];
  if (!accessToken) {
    res.send(403, 'Not Authorized');
    return next(false);
  }

  try {
    const decoded: Token = <Token>jwt.verify(accessToken, secretKey);
    if (decoded.clientId !== clientId) {
      throw new Error('CLIENT_ID does not match');
    }
    // TODO: should check email using grpc
    return next();
  } catch (e) {
    logger.error(e);
    res.send(403, 'Not Verified');
    return next(false);
  }
}

export default {
  checkAuthority,
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
  getAccountByEmail: responder(async (req) => {
    logger.debug(`[GetAccount] payload: ${JSON.stringify(req.body)}`);
    return await service.getAccountByEmail(req.body.email);
  }),
}