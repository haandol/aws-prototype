export interface IProduct {
  id: string;
  shop: string;
  date: number;
  from_at: number;
  to_at: number;
  name: string;
  price: number;
  img: string;
  live: string;
}

export interface IProgram {
  date: number;
  products: IProduct[];
}