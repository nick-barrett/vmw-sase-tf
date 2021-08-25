import requests
import time

api_url = '${api_url}'

api_headers = {
    'Authorization': 'Token ${api_key}'
}

api_body = {
    'activationKey': '${activation_key}'
}

edge_state = ''
est_seconds = 0

while edge_state != 'CONNECTED':
    if est_seconds > 600:
        # Give up after 10 minutes
        exit(1)

    time.sleep(3)
    est_seconds = est_seconds + 3
    
    resp = requests.post(
        api_url,
        json=api_body,
        headers=api_headers
    )

    edge_state = resp.json()['edgeState']

exit(0)
