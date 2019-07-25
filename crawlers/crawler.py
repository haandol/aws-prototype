import re
import json
import redis
import boto3
import requests
import traceback
from botocore.exceptions import ClientError
from decimal import Decimal
from datetime import datetime
from bs4 import BeautifulSoup


class Product:
    def __init__(self, data):
        self.id = data['id']
        self.shop = data['shop']
        self.date = int(data['date'])
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
            'date': self.date,
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
        
        fields = ['id', 'date', 'from_at', 'to_at', 'price', 'name', 'link', 'img']
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

    def _parse(self, content, today):
        products = []
        soup = BeautifulSoup(content, 'html.parser')
        items = soup.find_all('article', 'items')
        for item in items:
            if item.select('.onAirLast'):
                continue

            item_id = item.select('li.prd-item')[0]['id'].split('_')[1]

            times = item.select('.times')[0].get_text().split('-')
            if item.select('img'):
                img = 'http:' + item.select('img')[0]['src'] 
            else:
                img = 'http://#'

            info = item.select('dl.prd-info')[0]
            if info.select('.prd-name a'):
                name = info.select('.prd-name a')[0]
                link = self.BASE_URL + name['href']
            else:
                name = info.select('.prd-name')[0]
                link = 'http://#'
            
            if info.select('.price-info strong'):
                price = info.select('.price-info strong')
            else:
                price = 0

            products.append(Product({
                'id': '{}-{}-{}'.format(self.shop, today, item_id),
                'shop': self.shop,
                'date': today,
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
        return self._parse(response, today)

    def update_products(self, products):
        db = DynamoDB()
        table = db.resource.Table('Product')
        updated_product_ids = set()
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
                updated_product_ids.add(product.id)

        return updated_product_ids

    def update_cache(self, products):
        client = redis.Redis(
            host='reids.3kmfwp.0001.apn2.cache.amazonaws.com', port=6379, db=0
        )
        for product in products:
            client.set(product['id'], json.dumps(product.to_item()))


class DynamoDB:
    def __init__(self):
        self._resource = None

    @property
    def resource(self):
        if self._resource:
            return self._resource

        self._resource = boto3.resource('dynamodb', region_name='ap-northeast-2')
        return self._resource


def handler(event, context):
    agent = GSAgent()
    products = agent.crawl()
    updated_product_ids = agent.update_products(products)
    if updated_product_ids:
        try:
            agent.update_cache(filter(lambda x: x.id in updated_product_ids, products))
        except:
            traceback.print_exc()
            print('update cache error')