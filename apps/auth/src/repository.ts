import * as pg from 'pg';
import { Account, UserToken } from './interface';
import config from './config';
import logger from './logger';

const HOST = config.PG_HOST;
const PORT = config.PG_PORT;

class Repository {
  client: pg.Client;

  constructor() {
    this.client = new pg.Client({
      host: HOST,
      port: Number(PORT),
      database: 'authdb',
      user: 'master',
      password: 'aksekfls123',
    });
    this.initDB().catch((e) => {
      logger.error(e);
      throw e;
    });
  }

  async initDB() {
    await this.client.connect();
  }

  async createAccount(email: string, password: string): Promise<Account> {
    const res = await this.client.query({
      text: 'INSERT INTO users(email, password) VALUES($1, $2) RETURNING *',
      values: [email, password]
    });
    logger.debug(`INSERT: ${JSON.stringify(res.rows)}`);
    return {
      email: res.rows[0].email,
      password: res.rows[0].password,
      accessToken: res.rows[0].access_token,
      refreshToken: res.rows[0].refresh_token,
    };
  }

  async getAccountByEmail(email: string): Promise<Account> {
    const res = await this.client.query({
      text: 'SELECT * FROM users WHERE email = $1',
      values: [email],
    });
    logger.debug(`SELECT: ${JSON.stringify(res.rows)}`);
    return {
      email: res.rows[0].email,
      password: res.rows[0].password,
      accessToken: res.rows[0].access_token,
      refreshToken: res.rows[0].refresh_token,
    };
  }

  async updateToken(email: string, accessToken: string, refreshToken: string): Promise<UserToken> {
    const res = await this.client.query({
      text: 'UPDATE users SET access_token = $1, refresh_token = $2 WHERE email = $3 RETURNING email, access_token, refresh_token',
      values: [accessToken, refreshToken, email],
    });
    logger.debug(`UPDATE: ${JSON.stringify(res.rows)}`);
    return {
      email: res.rows[0].email,
      accessToken: res.rows[0].access_token,
      refreshToken: res.rows[0].refresh_token,
    };
  }
}

export default Repository;
