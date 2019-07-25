export interface Product {
  id: string;
  shop: string;
  from_at: number;
  to_at: number;
  price: number;
  link: string;
  img: string;
  name: string;
}

export interface Alarm {
  user_id: string;
  product_id: string;
}

export interface Token {
  clientId: string;
  email: string;
}