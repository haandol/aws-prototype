import { ProductProps } from '../interface/props';

const Product = (props: ProductProps) => (
  <div className="product-detail">
    <div className="time">
      <span>{props.item.from_at} - {props.item.to_at}</span>
      <span>LIVE</span>
    </div>
    <div className="info">
      <div className="img">
        <img src={props.item.img}/>
      </div>
      <div className="detail">
        <div className="name">{props.item.name}</div>
        <div className="price">{props.item.price}</div>
      </div>
    </div>
  </div>
);

export default Product;