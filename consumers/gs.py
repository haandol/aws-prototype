import json
import boto3
from botocore.exceptions import ClientError
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


SENDER = 'Vincent Lee <ldg55d@gmail.com>'
CHARSET = "UTF-8"


def generate_subject(name):
    return '[HsChart] 1-hour notice to live ({})'.format(name)


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


class Consumer:
    def __init__(self):
        self.db = DynamoDB()
        sqs = boto3.resource('sqs', region_name='ap-northeast-2')
        self.queue = sqs.get_queue_by_name(QueueName='alarm_queue')
        self.ses = boto3.client('ses', region_name='us-west-2')

    def consume(self):
        user_count = 0
        sent_count = 0
        for message in self.queue.receive_messages():
            D = json.loads(message.body)
            logger.info(D)
            product = D['product']
            user_ids = D['user_ids']
            try:
                self.send_alarm(product, user_ids)
            except ClientError as e:
                logger.error(e.response['Error']['Message'])
            else:
                for user_id in user_ids:
                    self.mark_sent(product['id'], user_id)
                message.delete()
                user_count += len(D['user_ids'])
                sent_count += 1

        return sent_count, user_count

    def send_alarm(self, product, recipients):
        logger.info('send_alarm to : {}'.format(recipients))
        response = self.ses.send_email(
            Source=SENDER,
            Destination={
                'ToAddresses': recipients,
            },
            Message={
                'Subject': {
                    'Charset': CHARSET,
                    'Data': generate_subject(product['name']),
                },
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': generate_body(product),
                    },
                },
            },
        )
        logger.info('Email sent! Message ID: {}'.format(response['MessageId']))

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
    consumer = Consumer()
    sent_count, user_count = consumer.consume()
    if sent_count > 0 and user_count > 0:
        logger.info('#{} messages has delivered to #{} users.'.format(sent_count, user_count))