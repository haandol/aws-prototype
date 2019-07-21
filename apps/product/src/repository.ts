import API, { graphqlOperation } from '@aws-amplify/api';
import config from './aws-exports';
import { Product } from './interface';

API.configure(config);

class Repository {
  constructor() {
  }

  async query(input: {[key: string]: any}): Promise<Product[]> {
    const productsQuery = `query products(
      $filter: TableProductFilterInput
) {
  products(filter: $filter) {
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
}
    `;
    console.log('!!!!', input);
    const products = await API.graphql(graphqlOperation(productsQuery));
    console.log('@@@@@', products);
    return <Product[]>products;
  }
}

export default Repository;
