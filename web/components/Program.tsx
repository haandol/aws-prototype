import Product from "./Product";
import { IProduct } from "../interface/interface";
import { ProgramProps } from "../interface/props";

const Program = (props: ProgramProps) => (
  <div className="productList">
    <div className="date">
      <strong>{props.item.date}</strong>
      <span>({props.item.products.length})</span>
    </div>
    {props.item.products.map((product: IProduct) => (
      <Product item={product} />
    ))}
  </div>
);

export default Program;