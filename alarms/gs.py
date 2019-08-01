import boto3
import requests
from datetime import datetime
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


BEFORE_MINUTES = 60     # alarm

SENDER = 'Vincent Lee <ldg55d@gmail.com>'
CHARSET = "UTF-8"


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
        to_at = add_minutes(now_time, BEFORE_MINUTES)

        fe = Attr('shop').eq('gs') & \
             Attr('date').eq(today) & \
             Attr('from_at').gt(now_time) & \
             Attr('from_at').lte(to_at)
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

    def mark_sent(self, user_id, product_id):
        table = self.db.resource.Table('Alarm')
        table.update_item(
            Key={
                'user_id': user_id,
                'product_id': product_id
            },
            UpdateExpression='SET is_send = :val1',
            ExpressionAttributeValues = {
                ':val1': 1
            }
        )

    def send_alarm(self, client, product, recipients):
        logger.info('send_alarm to : {}'.format(recipients))

        def generate_subject(product):
            return '[HsChart] 1-hour notice to live ({})'.format(
                product['name']
            )

        def generate_body(product):
            return '''
            <html>
            <body>
                <div><a href="{}">{}</a></div>
                <div>schedule: <strong>{} ~ {}</strong></div>
                <div>price: <strong>{}</strong></div>
            </body>
            </html>'''.format(
                product['link'],
                product['name'],
                product['from_at'],
                product['to_at'],
                product['price']
            )

        try:
            response = client.send_email(
                Source=SENDER,
                Destination={
                    'ToAddresses': recipients,
                },
                Message={
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': generate_subject(product),
                    },
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': generate_body(product),
                        },
                    },
                },
            )
        # Display an error if something goes wrong.	
        except ClientError as e:
            logger.error(e.response['Error']['Message'])
        else:
            logger.info('Email sent! Message ID: {}'.format(response['MessageId']))
        
        for user_id in recipients:
            self.mark_sent(user_id, product['id'])


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
    res = {}
    agent = Agent()
    now = datetime.now()
    today = now.strftime('%Y%m%d') 
    now_time = now.strftime('%H%M') 
    products = agent.fetch_products(int(today), int(now_time))
    if not products:
        return res

    client = boto3.client('ses', region_name='us-west-2')
    logger.info('get products: {}'.format(len(products)))
    for product in products:
        alarms = agent.fetch_alarms(product)
        logger.info('send alarms: {}'.format(len(alarms)))
        if alarms:
            agent.send_alarm(client,
                             product,
                             list(map(lambda x: x['user_id'], alarms)))
        res[product['id']] = len(alarms)
    return res