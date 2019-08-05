import json
import pytz
import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Attr
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


BEFORE_MINUTES = 60     # alarm


def add_minutes(now, d):
    hour, minute = divmod(d, 60)
    res = now + (hour*100) + minute
    if 59 < res % 100:
        res += 40
    if res > 2400:
        res -= 2400
    return res


def sub_minutes(now, d):
    hour, minute = divmod(d, 60)
    res = now - (hour*100) - minute
    if 59 < res % 100:
        res -= 40
    if res < 0:
        res += 2400
    return res


class Agent:
    def __init__(self):
        self.db = DynamoDB()
    
    def fetch_products(self, today, now_time):
        table = self.db.resource.Table('Product')
        from_limit = add_minutes(now_time, BEFORE_MINUTES)

        fe = Attr('shop').eq('gs') & \
             Attr('date').eq(today) & \
             Attr('to_at').gt(now_time) & \
             Attr('from_at').lte(from_limit)
        response = table.scan(
            IndexName='DateIndex',
            FilterExpression=fe,
        )
        products = response['Items']
        for product in products:
            logger.info('{}, {}, {}'.format(
                product['id'], product['from_at'], product['to_at']
            ))
        return products
    
    def fetch_alarms(self, product):
        table = self.db.resource.Table('Alarm')
        response = table.scan(
            IndexName='ProductIdIndex',
            FilterExpression=Attr('product_id').eq(product['id']) & Attr('is_send').eq(0),
        )
        alarms = response['Items']
        return alarms

    def dispatch_alarm(self, queue, product, user_ids):
        Product = {
            'id': product['id'],
            'link': product['link'],
            'name': product['name'],
            'from_at': int(product['from_at']),
            'to_at': int(product['to_at']),
            'price': int(product['price'])
        }
        queue.send_message(MessageBody=json.dumps({
            'product': Product,
            'user_ids': user_ids
        }))


class DynamoDB:
    def __init__(self):
        self._resource = None

    @property
    def resource(self):
        if self._resource:
            return self._resource

        self._resource = boto3.resource(
            'dynamodb', region_name='ap-northeast-2'
        )
        return self._resource


def handler(event, context):
    agent = Agent()
    now = datetime.now(pytz.timezone('Asia/Seoul'))
    today = now.strftime('%Y%m%d') 
    now_time = now.strftime('%H%M') 
    products = agent.fetch_products(int(today), int(now_time))
    if not products:
        return

    sqs = boto3.resource('sqs', region_name='ap-northeast-2')
    logger.info('get products: {}'.format(len(products)))
    for product in products:
        alarms = agent.fetch_alarms(product)
        logger.info('dispatch alarms: {} - {}'.format(product['id'], len(alarms)))
        if alarms:
            agent.dispatch_alarm(sqs.get_queue_by_name(QueueName='alarm_queue'),
                                 product,
                                 list(map(lambda x: x['user_id'], alarms)))