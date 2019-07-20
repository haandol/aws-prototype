const pg = require('pg');

const HOST = 'authdb.cggrl7pirkvu.ap-northeast-2.rds.amazonaws.com'
const PORT = process.env.PG_PORT || 5432;

client = new pg.Client({
  host: HOST,
  port: Number(PORT),
  database: 'authdb',
  user: 'master',
  password: 'aksekfls123',
});

async function run() {
  await client.connect();

  console.log('Create table');
  await client.query({
    text: 'CREATE TABLE users ( \
email VARCHAR(256) PRIMARY KEY, \
password VARCHAR(256) NOT NULL, \
access_token VARCHAR(512), \
refresh_token VARCHAR(512) \
);'
  });

  /*
  const res = await client.query({
    text: 'SELECT * FROM users WHERE email = $1',
    values: ['ldg55d@gmail.com']
  });
  console.log(res.rows[0]);
  */

  /*
  console.log('Drop table');
  await client.query({
    text: 'DROP TABLE users;'
  });
  */

  await client.end();
}

run().catch((e) => {
  client.end();
  console.error(e);
  throw e;
});