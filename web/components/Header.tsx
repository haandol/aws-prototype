import Link from 'next/link';

const Header = () => (
  <nav>
    <Link href="/">
      <a>Home</a>
    </Link>
    <Link href="/signin">
      <a>Signin</a>
    </Link>
  </nav>
);

export default Header;