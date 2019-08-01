import * as dotenv from 'dotenv';
dotenv.config();

export default {
  AUTH_URL: process.env.AUTH_URL || 'http://localhost:8001',
  PRODUCT_URL: process.env.PRODUCT_URL || 'http://localhost:8000',
}