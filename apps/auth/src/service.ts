import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import Repository from './repository';
import logger from './logger';
import { UserToken } from './interface';

const SALT_ROUNDS = 9;

class Service {
  repository: Repository;

  constructor(private clientId: string, private secretKey: string) {
    this.repository = new Repository();
  }

  async _generateHashedPassword(plainText: string): Promise<string> {
      const salt = await bcrypt.genSalt(SALT_ROUNDS);
      return await bcrypt.hash(plainText, salt);
  }

  _generateAccessToken(clientId: string, email: string): string {
      return jwt.sign(
        {
          clientId: clientId,
          email: email,
          password: 'password',
        },
        this.clientId,
        { expiresIn: '365d' }
      );
  }

  private async _generateRefreshToken(accessToken: string): Promise<string> {
    return await bcrypt.hash(accessToken, 6);
  }

  async _checkPassword(password1: string, password2: string){
    if (!await bcrypt.compare(password1, password2)) {
      throw new Error('WRONG_PASSWORD');
    }
  }

  _isValidToken(accessToken: string): boolean {
    try {
      jwt.verify(accessToken, this.secretKey);
      return true;
    } catch (e) {
      logger.error(e);
    }
    return false;
  }

  async getTokenUsingPassword(email: string, password: string): Promise<UserToken> {
    let account = await this.repository.getAccountByEmail(email);
    const hashedPass = await this._generateHashedPassword(password);
    if (!account) {
      account = await this.repository.createAccount(email, hashedPass);
    }

    if (account.accessToken) {  // signin
      await this._checkPassword(password, account.password);
      return { 
        email: account.email,
        accessToken: account.accessToken || '',
        refreshToken: account.refreshToken || '',
      };
    } else {    // signup
      const accessToken = await this._generateAccessToken(email, hashedPass);
      const refreshToken = await this._generateRefreshToken(accessToken);
      return await this.repository.updateToken(account.email, accessToken, refreshToken);
    }
  }
}

export default Service;
