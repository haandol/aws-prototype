import React from 'react';
import axios from 'axios';
import config from '../config';
import Layout from '../components/Layout';
import Router from 'next/router';

interface IProps {
}

interface IState {
  email: string;
  password: string;
}

class Signin extends React.Component<IProps, IState> {
  private _submitSignin: (e: any) => Promise<void>;

  constructor(props: IProps) {
    super(props);

    this.state = {
      email: '',
      password: '',
    }

    this._submitSignin = async (e:React.FormEvent<HTMLFormElement>) => {
      e.preventDefault();

      const { email, password } = this.state;
      if (!email) {
        alert('No Email');
        return;
      } else if (!password) {
        alert('No Password');
        return;
      }

      try {
        const res: any = await axios({
          method: 'post',
          url: config.AUTH_URL + '/signin',
          data: {
            email: email,
            password: password,
          },
          timeout: 3000,
          responseType: 'json',
        });

        const accessToken = res && res.data && res.data.data && res.data.data.accessToken;
        if (!accessToken) {
          alert('No access token');
        } else {
          localStorage.setItem('token', accessToken);
        }
        Router.push('/');
      } catch(e) {
        console.error(e);
        alert('Failed to get token');
      }
   }
  }

  onChangeEmail(email: string) {
    this.setState({ email });
  }

  onChangePassword(password: string) {
    this.setState({ password });
  }

  render() {
    const { email, password } = this.state;

    return (
      <Layout>
        <div className="signin-form">
          <h1>Signin</h1>
          <form onSubmit={this._submitSignin}>
            <label>
              Email:
              <input type="text" placeholder="email" value={email} onChange={e => this.onChangeEmail(e.target.value)} />
            </label>
            <label>
              Password:
              <input type="password" value={password} onChange={e => this.onChangePassword(e.target.value)} />
            </label>
            <input type="submit" value="Signin" />
          </form>
        </div>
      </Layout>
    );
  }
}

export default Signin;