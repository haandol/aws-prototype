import * as _ from 'lodash';
import moment from 'moment';
import Alarm from './Alarm';
import { ProductProps } from '../interface/props';

const Product = (props: ProductProps) => {
  const now = moment();
  const today: number = parseInt(now.format('YYYYMMDD'));
  const time: number = parseInt(now.format('km'));
  if (props.item.date === today && props.item.from_at <= time && time <= props.item.to_at) {
    props.item.live = 'LIVE';
  }

  const email = localStorage.getItem('email');
  if (!email) {
    alert('No email on localStorage');
    return (<div>No email on localStorage</div>);
  }

  return (
    <div className="product-detail">
      <div className="time">
        <span>{props.item.from_at} - {props.item.to_at}</span>
        <strong>{props.item.live}</strong>
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
      <Alarm userId={email} productId={props.item.id} />
    </div>
  );
};

export default Product;