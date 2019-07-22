import API, { graphqlOperation } from '@aws-amplify/api';
import config from './config';
import { Product } from './interface';

API.configure(config);

class Repository {
  constructor() {
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
    const products = await API.graphql(graphqlOperation(query, {filter: input}));
    return <Product[]>products;
  }
}

export default Repository;
