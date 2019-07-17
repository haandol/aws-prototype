import requests
from datetime import datetime
from bs4 import BeautifulSoup

class Agent:
    def __init__(self):
        self.headers = {
            'user-agent': 'Mozilla/5.0 Chrome/75.0.3770.142 Safari/537.36'
        }
        self.url = 'https://www.gsshop.com/shop/tv/tvScheduleDetail.gs?today='

    def fetch(self, today):
        res = requests.get(self.url + today, headers=self.headers)
        return res.content

    def parse(self, content):
        soup = BeautifulSoup(content, 'html.parser')
        times = soup.select('span.times')
        print(list(map(lambda x: x.get_text(), times)))
        return soup

    def crawl(self):
        today = datetime.now().strftime('%Y%m%d') 
        data = self.fetch(today)
        return self.parse(data)


agent = Agent()
agent.crawl()