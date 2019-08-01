import React from 'react';
import axios from 'axios';

interface IProps {
  shop: string;
  userId: string;
  productId: string;
}

interface IState {
}

class Alarm extends React.Component<IProps, IState> {
  private _onSetAlarm: (e: any) => Promise<void>;
  private _onUnsetAlarm: (e: any) => Promise<void>;

  constructor(props: IProps) {
    super(props);

    this._onSetAlarm = async(e: any) => {
      e.preventDefault();

      const res: any = await axios({
        method: 'post',
        url: '/product/alarm',
        data: {
          product_id: props.productId,
          shop: props.shop,
        },
        headers: {
          'authorization': localStorage.getItem('token'),
        },
        timeout: 3000,
        responseType: 'json',
      });
      console.log(res);
      alert('Setted Alarm');
    };

    this._onUnsetAlarm = async(e: any) => {
      e.preventDefault();
      const res: any = await axios({
        method: 'delete',
        url: '/product/alarm',
        data: {
          product_id: props.productId,
          shop: props.shop,
        },
        headers: {
          'authorization': localStorage.getItem('token'),
        },
        timeout: 3000,
        responseType: 'json',
      });
      console.log(res);
      alert('Unsetted Alarm');
    }
  }

  render() {
    return (
      <div className="alarm">
        <button onClick={this._onSetAlarm}>알람설정</button>
        <button onClick={this._onUnsetAlarm}>알람해제</button>
      </div>
    );
  }
}

export default Alarm;