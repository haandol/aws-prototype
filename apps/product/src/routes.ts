import * as restify from 'restify';
import Service from './service';
import { Product, Alarm } from './interface';
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
  healthcheck: responder(async (req): Promise<void> => {
    logger.debug(`[Healthcheck] ${JSON.stringify(req.query)}`);
    return;
  }),
  getProduct: responder(async (req): Promise<Product> => {
    logger.debug(`[GetProduct] ${JSON.stringify(req.query)}`);
    return await service.getProduct(req.query.id, req.query.shop);
  }),
  listProducts: responder(async (req): Promise<Product[]> => {
    logger.debug(`[ListProducts] ${JSON.stringify(req.body)}`);
    return await service.listProducts(req.body);
  }),
  listAlarms: responder(async (req): Promise<Alarm[]> => {
    logger.debug(`[ListAlarms] ${JSON.stringify(req.body)}`);
    return await service.listAlarms(req.body);
  }),
  setAlarm: responder(async (req): Promise<Alarm> => {
    logger.debug(`[SetAlarm] ${JSON.stringify(req.body)}`);
    const email = req.body._session.email;
    return await service.setAlarm(email, req.body.product_id, req.body.shop);
  }),
  deleteAlarm: responder(async (req): Promise<Alarm> => {
    logger.debug(`[DelAlarm] ${JSON.stringify(req.body)}`);
    const email = req.body._session.email;
    return await service.deleteAlarm(email, req.body.product_id);
  }),
}