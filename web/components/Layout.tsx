import Header from './Header';

interface IProps {
  children: any;
}

const Layout = (props: IProps) => (
  <div>
    <Header />
    {props.children}
  </div>
);

export default Layout