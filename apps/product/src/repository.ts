import * as _ from 'lodash';
import API, { graphqlOperation } from '@aws-amplify/api';
import config from './config';
import { Alarm, Product } from './interface';
import logger from './logger';
import { GraphQLResult } from '@aws-amplify/api/lib/types';

logger.info(`configure AWS API: ${JSON.stringify(config)}`);
API.configure(config);

class Repository {
  async listAlarms(input: {[key: string]: any}): Promise<Alarm[]> {
    const query = `query listAlarms (
      $filter: TableAlarmFilterInput
) {
  listAlarms(filter: $filter) {
    items {
      user_id
      product_id
      is_send
    }
  }
}`;
    const filter = _.omit(input, ['_session']);
    const alarms = await API.graphql(graphqlOperation(query, { filter }));
    return <Alarm[]>alarms;
  }

  async setAlarm(userId: string, productId: string, shop: string): Promise<Alarm> {
    const product = await this.getProduct(productId, shop);
    if (!product) {
      throw new Error(`There is no such product: ${productId}`);
    }

    const mutation = `mutation createAlarm (
  $input: CreateAlarmInput
) {
  createAlarm(input: $input) {
    user_id
    product_id
  }
}`;
    const input = {user_id: userId, product_id: productId}; 
    const res: any = await API.graphql(graphqlOperation(
      mutation, {input}
    ));
    return res.data.createAlarm;
  }

  async deleteAalrm(userId: string, productId: string): Promise<Alarm> {
    const mutation = `mutation deleteAlarm (
  $input: DeleteAlarmInput
) {
  deleteAlarm(input: $input) {
    user_id
    product_id
    is_send
  }
}`;
    const input = {user_id: userId, product_id: productId};
    const res: any = await API.graphql(graphqlOperation(
      mutation, {input}
    ));
    return res.data.deleteAlarm;
  }

  async getProduct(id: string, shop: string): Promise<Product> {
    const query = `query getProduct (
  $id: String!
  $shop: String!
) {
  getProduct(id: $id, shop: $shop) {
    id
    shop
    date
    from_at
    to_at
    name
    price
    link
    img
  }
}`;
    const product = await API.graphql(graphqlOperation(query, {id, shop}));
    return <Product>product;
  }

  async listProducts(input: {[key: string]: any}): Promise<Product[]> {
    const query = `query listProducts (
      $filter: TableProductFilterInput
) {
  listProducts(filter: $filter) {
    items {
      id
      shop
      date
      from_at
      to_at
      name
      price
      link
      img
    }
  }
}`;
    const filter = _.omit(input, ['_session']);
    const products = <GraphQLResult>(await API.graphql(graphqlOperation(query, { filter })));
    const data: any = products.data;
    if (!data || !data.listProducts) {
      return [];
    }

    return <Product[]>_.sortBy(data.listProducts.items, ['from_at', 'to_at']);
  }
}

export default Repository;
