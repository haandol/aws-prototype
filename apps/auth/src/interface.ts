export interface Account {
  email: string;
  password: string;
  accessToken?: string;
  refreshToken?: string;
}

export interface UserToken {
  email: string;
  accessToken: string;
  refreshToken: string; 
}

export interface Token {
  clientId: string;
  email: string;
  password: string;
}