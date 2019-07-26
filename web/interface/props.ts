import { IProduct, IProgram } from './interface';

export interface InitialProps {
  [key: string]: any;
}

export interface ProductProps extends InitialProps{
  item: IProduct;
}

export interface ProgramProps extends InitialProps{
  item: {
    date: number;
    products: IProduct[];
  }
}

export interface IndexProps extends InitialProps{
  programs: IProgram[];
}