import Product from "./Product";
import { IProduct } from "../interface/interface";
import { ProgramProps } from "../interface/props";

const Program = (props: ProgramProps) => (
  <div className="productList">
    <div>{props.item.products.length}</div>
    <div className="date">{props.item.date}</div>
    {props.item.products.map((product: IProduct) => {
      <Product item={product}>
      </Product>
    })};
  </div>
);

export default Program;