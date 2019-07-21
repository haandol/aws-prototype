import Repository from './repository';
import { Product } from './interface';


class Service {
  repository: Repository;

  constructor() {
    this.repository = new Repository();
  }

  async query(input: {[key: string]: any}): Promise<Product[]> {
    return await this.repository.query(input);
  }
}

export default Service;
