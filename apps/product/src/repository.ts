import API, { graphqlOperation } from '@aws-amplify/api';
import config from './aws-exports';
import { Product } from './interface';

API.configure(config);

class Repository {
  constructor() {
  }

  async query(input: {[key: string]: any}): Promise<Product[]> {
    const productsQuery = `query listProducts (
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
    const products = await API.graphql(graphqlOperation(productsQuery));
    return <Product[]>products;
  }
}

export default Repository;
