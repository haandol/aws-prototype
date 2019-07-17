import re
import requests
from datetime import datetime
from bs4 import BeautifulSoup

class Agent:
    def __init__(self):
        self.headers = {
            'user-agent': 'Mozilla/5.0 Chrome/75.0.3770.142 Safari/537.36'
        }
        self.URL = 'https://www.gsshop.com/shop/tv/tvScheduleDetail.gs?today='
        self.BASE_URL = 'http://www.gsshop.com'

    def _fetch(self, today):
        res = requests.get(self.URL + today, headers=self.headers)
        return res.content

    def _refine_times(self, times):
        return list(map(
            lambda x: list(map(int, x.strip().split(':'))),
            times
        ))

    def _refine_price(self, price):
        if not price:
            return 0
        
        text = price[0].get_text().replace(',', '')
        return int(re.search(r'(\d+)', text).group(0))

    def _parse(self, content):
        result = []
        soup = BeautifulSoup(content, 'html.parser')
        items = soup.find_all('article', 'items')
        for item in items:
            product = {}
            times = self._refine_times(item.select('.times')[0].get_text().split('-'))
            item_id = item.select('li.prd-item')[0]['id'].split('_')[1]
            img = 'http:' + item.select('img')[0]['src']
            info = item.select('dl.prd-info')[0]
            name = info.select('.prd-name a')[0]
            link = self.BASE_URL + name['href']
            price = info.select('.price-info strong')
            product = {
                'time': {
                    'from': times[0],
                    'to': times[1]
                },
                'id': item_id,
                'img': img,
                'name': name.get_text(),
                'link': link,
                'price': self._refine_price(price)
            }
            result.append(product)
        return result

    def crawl(self):
        today = datetime.now().strftime('%Y%m%d') 
        data = self._fetch(today)
        return self._parse(data)


agent = Agent()
print(agent.crawl())