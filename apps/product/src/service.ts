import Repository from './repository';
import { Product } from './interface';

class Service {
  repository: Repository;

  constructor() {
    this.repository = new Repository();
  }

  async getProduct(id: string, shop: string): Promise<Product> {
    return await this.repository.getProduct(id, shop);
  }

  async listProducts(input: {[key: string]: any}): Promise<Product[]> {
    return await this.repository.listProducts(input);
  }
}

export default Service;
