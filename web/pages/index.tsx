import axios from 'axios';
import moment from 'moment';
import Program from '../components/Program';
import { IProgram } from '../interface/interface';
import { IndexProps } from '../interface/props';
import config from '../config';
import Layout from '../components/Layout';

const Index = (props: IndexProps) => (
  <Layout>
    <div className="program">
      <div>{props.programs.length}</div>
      {props.programs.map((program: IProgram) => {
        <Program item={program}></Program>
      })}
    </div>
  </Layout>
);

Index.getInitialProps = async() => {
  if (typeof(Storage) === "undefined") {
    console.debug('No localStorage');
    return {
      programs: [],
    };
  }

  const token = localStorage.getItem('token');
  if (!token) {
    console.debug('No Token');
    return {
      programs: [],
    };
  }

  let programs = [];
  const today = moment().format('YYYYMMDD');
  try {
    const res = await axios({
      method: 'post',
      url: config.API_URL + '/products',
      data: {
        date: {eq: today},
      },
      headers: {
        'authorization': token,
      },
      timeout: 3000,
      responseType: 'json',
    });

    programs.push({
      date: today,
      products: res.data.data.data.listProducts.items,
    });
  } catch (e) {
    console.error(e);
  }
  return { programs };
}

export default Index;