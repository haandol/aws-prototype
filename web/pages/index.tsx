import axios from 'axios';
import moment from 'moment';
import Program from '../components/Program';
import { IProgram } from '../interface/interface';
import { IndexProps } from '../interface/props';
import Layout from '../components/Layout';

const Index = (props: IndexProps) => (
  <Layout>
    <div className="program">
      <div>Programs: {props.programs.length}</div>
      {props.programs.map((program: IProgram) => (
        <Program item={program} />
      ))}
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

  const programs = [];
  const today = moment().format('YYYYMMDD');
  try {
    const res = await axios({
      method: 'post',
      url: '/product/list',
      data: {
        date: {eq: today},
      },
      headers: {
        'authorization': token,
      },
      timeout: 3000,
      responseType: 'json',
    });

    const products = res.data.data;
    console.log(`products: ${products.length}`);
    programs.push({
      date: today,
      products,
    });
  } catch (e) {
    console.error(e);
  }
  return { programs };
}

export default Index;