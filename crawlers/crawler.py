import re
import boto3
import requests
from botocore.exceptions import ClientError
from decimal import Decimal
from datetime import datetime
from bs4 import BeautifulSoup


class Product:
    def __init__(self, data):
        self.id = data['id']
        self.shop = data['shop']
        self.from_at = self._refine_times(data['from_at'])
        self.to_at = self._refine_times(data['to_at'])
        self.img = data['img']
        self.name = data['name']
        self.link = data['link']
        self.price = self._refine_price(data['price'])

    def _refine_times(self, times):
        if isinstance(times, Decimal):
            return times

        return Decimal(times.replace(':', ''))

    def _refine_price(self, price):
        if isinstance(price, Decimal):
            return price

        if not price:
            return 0
        
        text = price[0].get_text().replace(',', '')
        return Decimal(re.search(r'(\d+)', text).group(0))

    def to_item(self):
        return {
            'id': self.id, 
            'shop': self.shop,
            'from_at': self.from_at, 
            'to_at': self.to_at, 
            'img': self.img, 
            'name': self.name, 
            'link': self.link, 
            'price': self.price, 
        }

    def __eq__(self, other):
        if not isinstance(other, Product):
            return False
        
        fields = ['id', 'from_at', 'to_at', 'price', 'name', 'link', 'img']
        for field in fields:
            if getattr(self, field) != getattr(other, field):
                print(getattr(self, field),  getattr(other, field))
                return False
        return True
 

class GSAgent:
    def __init__(self):
        self.shop = 'gs'
        self.headers = {
            'user-agent': 'Mozilla/5.0 Chrome/75.0.3770.142 Safari/537.36'
        }
        self.URL = 'https://www.gsshop.com/shop/tv/tvScheduleDetail.gs?today='
        self.BASE_URL = 'http://www.gsshop.com'

    def _fetch(self, today):
        res = requests.get(self.URL + today, headers=self.headers, timeout=3)
        return res.content

    def _parse(self, content):
        products = []
        soup = BeautifulSoup(content, 'html.parser')
        items = soup.find_all('article', 'items')
        for item in items:
            item_id = item.select('li.prd-item')[0]['id'].split('_')[1]
            times = item.select('.times')[0].get_text().split('-')
            img = 'http:' + item.select('img')[0]['src']
            info = item.select('dl.prd-info')[0]
            name = info.select('.prd-name a')[0]
            link = self.BASE_URL + name['href']
            price = info.select('.price-info strong')

            products.append(Product({
                'id': '{}-{}'.format(self.shop, item_id),
                'shop': self.shop,
                'from_at': times[0].strip(),
                'to_at': times[1].strip(),
                'img': img,
                'name': name.get_text().strip(),
                'link': link,
                'price': price,
            }))
        return products

    def crawl(self):
        today = datetime.now().strftime('%Y%m%d') 
        response = self._fetch(today)
        return self._parse(response)

    def update_products(self, db, products):
        table = db.get_or_create_table('Product')
        updated_products = []
        for product in products:
            old = table.get_item(
                Key={
                    'id': product.id,
                    'shop': product.shop,
                }
            )
            if 'Item' not in old or (Product(old['Item']) != product):
                table.put_item(
                    Item=product.to_item(),
                )
                updated_products.append(product.id)

        return updated_products


class DynamoDB:
    def __init__(self):
        self._resource = None

    @property
    def resource(self):
        if self._resource:
            return self._resource

        self._resource = boto3.resource('dynamodb',
                                       region_name='ap-northeast-2')
        return self._resource

    def get_or_create_table(self, table_name):
        try:
            params = dict(
                TableName=table_name,
                KeySchema=[
                    {'AttributeName': 'id', 'KeyType': 'HASH'},
                    {'AttributeName': 'shop', 'KeyType': 'RANGE'},
                ],
                AttributeDefinitions=[
                    {'AttributeName': 'id', 'AttributeType': 'S'},
                    {'AttributeName': 'shop', 'AttributeType': 'S'},
                ],
                ProvisionedThroughput={
                    'ReadCapacityUnits': 10,
                    'WriteCapacityUnits': 10,
                },
            )
            client = boto3.client('dynamodb',
                                  region_name='ap-northeast-2')
            client.create_table(**params)
            waiter = client.get_waiter('table_exists')
            waiter.wait(TableName=table_name)
        except ClientError as e:
            if e.response['Error']['Code'] != 'ResourceInUseException':
                raise e
        return self.resource.Table(table_name)


def handler(event, context):
    agent = GSAgent()
    products = agent.crawl()
    db = DynamoDB()
    updated_product_ids = agent.update_products(db, products)
    # if updated_product_ids: do something