import requests
import time

api_url = '${api_url}'

api_headers = {
    'Authorization': 'Token ${api_key}'
}

activation_keys = '${activation_keys}'.split(',')

api_bodies = [
    {
        'activationKey': '{}'.format(key)
    }
    for key in activation_keys
]

est_seconds = 0

while len(api_bodies) > 0:
    if est_seconds > 600:
        # Give up after 10 minutes
        exit(1)

    time.sleep(3)
    est_seconds = est_seconds + 3

    completed_bodies = []

    for index, api_body in enumerate(api_bodies):
        resp = requests.post(
            api_url,
            json=api_body,
            headers=api_headers
        )

        if resp.json()['edgeState'] == 'CONNECTED':
            completed_bodies.append(index)

    # loop from last item so that largest is always removed first
    # otherwise indices will be modified
    for index in reversed(completed_bodies):
        # remove the edge from the list of edges being checked
        del api_bodies[index]

exit(0)
