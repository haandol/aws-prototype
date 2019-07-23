export interface IProduct {
  id: string;
  shop: string;
  date: Date;
  from_at: number;
  to_at: number;
  name: string;
  price: number;
  img: string;
}

export interface IProgram {
  date: Date;
  products: IProduct[];
}