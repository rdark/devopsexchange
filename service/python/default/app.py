#!/usr/bin/env python
import os
import json
from enum import IntEnum, unique

from flask import Flask, Response
from datadog import DogStatsd
from pydantic.dataclasses import dataclass


@unique
class Gender(IntEnum):
    MALE = 0
    FEMALE = 1
    OTHER = 2


@dataclass
class Config:
    gender: Gender
    metrics_host: str
    env_name: str
    hostname: str


class ConfigEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Config):
            skip_keys = ('__initialised__', 'gender')
            overrides = {'gender': obj.gender.name}
            main_dict = {k: v for k, v in obj.__dict__.items() if k not in skip_keys}
            return {**overrides, **main_dict}
        return json.JSONEncoder.default(self, obj)


config = Config(
    gender=getattr(Gender, os.environ['GENDER']),
    metrics_host=(os.getenv('METRICS_HOSTNAME', 'localhost')),
    env_name=os.environ['ENV_NAME'],
    hostname=os.environ['HOSTNAME'],
)

statsd = DogStatsd(host=config.metrics_host)
statsd.constant_tags = [
    f'gender:{config.gender.name}',
    f'hostname:{config.hostname}',
    f'env_name:{config.env_name}',
]

app = Flask(__name__)


@app.route('/config', methods=['GET'])
def get_config():
    response = Response(
        json.dumps(config, cls=ConfigEncoder, indent=2),
        status=200,
        mimetype='application/json'
    )
    statsd.increment('success', tags=[
        'method:GET',
        'function:get_config',
        f'status_code:{response.status_code}',
    ])
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0')
