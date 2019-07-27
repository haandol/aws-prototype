import Repository from './repository';
import { Alarm, Product } from './interface';

class Service {
  repository: Repository;

  constructor() {
    this.repository = new Repository();
  }

  async setAlarm(userId: string, productId: string, shop: string): Promise<Alarm> {
    return await this.repository.setAlarm(userId, productId, shop);
  }

  async deleteAlarm(userId: string, productId: string): Promise<Alarm> {
    return await this.repository.deleteAalrm(userId, productId);
  }

  async listAlarms(input: {[key: string]: any}): Promise<Alarm[]> {
    return await this.repository.listAlarms(input);
  }

  async getProduct(id: string, shop: string): Promise<Product> {
    return await this.repository.getProduct(id, shop);
  }

  async listProducts(input: {[key: string]: any}): Promise<Product[]> {
    return await this.repository.listProducts(input);
  }
}

export default Service;
