import logging
from urllib.parse import urljoin

import requests
from pydantic import BaseModel

CLOUD_API_BASE_URI = "https://api.redislabs.com/v1/"
REFRESH_STAT_INTERVAL = 20

class DatabaseId(BaseModel):
    """ Simple model for databases in an subscription """
    database_id: int
    subscription_id: str

class MetricsFetcher():
    """ Get database metrics from the Redis Cloud API """
    def __init__(self, endpoint_host, api_key, api_secret):
        self.endpoint_host = endpoint_host
        self.api_key = api_key
        self.api_secret = api_secret
        self.databases = []
        self.fetch_count = 0

    def fetch_database_metrics(self):
        if not self._database_found():
            self._get_database_metadata()
        elif self.fetch_count > REFRESH_STAT_INTERVAL:
            self.fetch_count = 0
            self.databases = []
            self._get_database_metadata()
        self.fetch_count += 1
        return self._get_database_stats()
   
    def _get_database_metadata(self):
        response = self._get_subscriptions()
        if "subscriptions" not in response:
            return
        for subscription in response["subscriptions"]:
            if self._database_found():
                return
            dbs = self._get_databases(subscription)
            if "subscription" in dbs and len(dbs["subscription"]) > 0:
                for database in dbs["subscription"][0]["databases"]:
                    if "activeActiveRedis" in database:
                        for crdb in database["crdbDatabases"]:
                            self._store_database_values(crdb, subscription["id"], database["databaseId"])
                    else:
                        self._store_database_values(database, subscription["id"], database["databaseId"])
    
    def _store_database_values(self, database, subscription_id, database_id):
        if "privateEndpoint" in database and self.endpoint_host in database["privateEndpoint"]:
            db = DatabaseId(database_id=database_id,
                            subscription_id=subscription_id)
            self.databases.append(db)


    def _database_found(self):
        return len(self.databases) > 0
            
    # Helper for the /subscriptions endpoint
    def _get_subscriptions(self):
        url = urljoin(CLOUD_API_BASE_URI, "subscriptions")
        response = self._url_fetch(url)
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 401:
            logging.error(f"Unable to authenticate: {response}")
            return {}

    # Helper for the /subscriptions/{ID}/databases endpoint
    def _get_databases(self, subscription):
        id = subscription["id"]
        url = urljoin(CLOUD_API_BASE_URI, f"subscriptions/{id}/databases")
        response = self._url_fetch(url)
        if response.status_code == 200:
            return response.json()

    # Helper for the /subscriptions/{ID}/databases/{ID} endpoint
    def _get_database_stats(self):
        stats = []
        for database in self.databases:
            url = urljoin(CLOUD_API_BASE_URI, f"subscriptions/{database.subscription_id}/databases/{database.database_id}")
            response = self._url_fetch(url)
            if response.status_code == 200:
                stats.append(response.json())
        return stats
        

    # Perform an authorized GET request against the provided url
    def _url_fetch(self, url):
        headers = {
            "Content-Type": "application/json",
            "User-Agent": "CloudExporter",
            "x-api-key": self.api_key,
            "x-api-secret-key": self.api_secret
        }
        return requests.get(
            url,
            headers=headers,
            allow_redirects=True,
            verify=True
        )