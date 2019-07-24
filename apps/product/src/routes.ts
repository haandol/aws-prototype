import * as restify from 'restify';
import Service from './service';
import { Product } from './interface';
import logger from './logger';

const service: Service = new Service();

function responder(handler: (req: restify.Request) => Promise<any>) {
  return async (req: restify.Request, res: restify.Response, next: restify.Next) => {
    try {
      const data = await handler(req);
      res.send(200, { data });
      return next()
    } catch (e) {
      logger.error(e);
      res.send(503, {
        err: e.toString(),
        req: req.body || {},
      });
      return next(false);
    }
  }
}

export default {
  setAlarm: responder(async (req): Promise<Product> => {
    const email = req.body._session.email;
    return await service.setAlarm(email, req.body.id, req.body.shop);;
  }),
  getProduct: responder(async (req): Promise<Product> => {
    return await service.getProduct(req.query.id, req.query.shop);;
  }),
  listProducts: responder(async (req): Promise<Product[]> => {
    return await service.listProducts(req.body);;
  })
}