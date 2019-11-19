#!/usr/bin/env python
import os
import json

from flask import Flask, Response
from datadog import DogStatsd

config = {
    "gender": "MALE",
    "metrics_host": os.getenv('METRICS_HOSTNAME', 'localhost'),
    "hostname": os.environ['HOSTNAME'],
    "env_name": os.environ['ENV_NAME'],
}

statsd = DogStatsd(host=config["metrics_host"])
statsd.constant_tags = [
    f'gender:{config["gender"]}',
    f'hostname:{config["hostname"]}',
    f'env_name:{config["env_name"]}',
]

app = Flask(__name__)


@app.route('/', methods=['GET'])
def get_index():
    response = Response(
        json.dumps(config, indent=2),
        status=200,
        mimetype='application/json'
    )
    statsd.increment('success', tags=[
        'method:GET',
        'function:get_index',
        f'status_code:{response.status_code}',
    ])
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0')
