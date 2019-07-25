import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import Repository from './repository';
import { Account, UserToken } from './interface';
import config from './config';
import logger from './logger';

const CLIENT_ID = config.CLIENT_ID;
const SECRET_KEY = config.SECRET_KEY;
const SALT_ROUNDS = 9;
const DUMMY_PASS = 'drowssap';
const expiresIn = '365d';

class Service {
  repository: Repository;

  constructor() {
    this.repository = new Repository();
  }

  async _generateHashedPassword(plainText: string): Promise<string> {
    const salt = await bcrypt.genSalt(SALT_ROUNDS);
    return await bcrypt.hash(plainText, salt);
  }

  _generateAccessToken(email: string): string {
    return jwt.sign(
        {
          clientId: CLIENT_ID,
          email: email,
          password: DUMMY_PASS,
        },
        SECRET_KEY,
        { expiresIn },
      );
  }

  private async _generateRefreshToken(accessToken: string): Promise<string> {
    return await bcrypt.hash(accessToken, SALT_ROUNDS);
  }

  async _checkPassword(password1: string, password2: string){
    if (!await bcrypt.compare(password1, password2)) {
      throw new Error('WRONG_PASSWORD');
    }
  }

  async getTokenUsingPassword(email: string, password: string): Promise<UserToken> {
    let account = await this.repository.getAccountByEmail(email);
    const hashedPass = await this._generateHashedPassword(password);
    if (!account) {
      account = await this.repository.createAccount(email, hashedPass);
    }

    if (account.accessToken) {  // signin
      logger.debug('signin');
      await this._checkPassword(password, account.password);
      return { 
        email: account.email,
        accessToken: account.accessToken || '',
        refreshToken: account.refreshToken || '',
      };
    } else {    // signup
      logger.debug('signup');
      const accessToken = await this._generateAccessToken(email);
      const refreshToken = await this._generateRefreshToken(accessToken);
      return await this.repository.updateToken(account.email, accessToken, refreshToken);
    }
  }

  async getAccountByEmail(email: string): Promise<Account> {
    return await this.repository.getAccountByEmail(email);
  }
}

export default Service;
