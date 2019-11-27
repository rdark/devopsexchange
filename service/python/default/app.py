#!/usr/bin/env python
import os
import json
from enum import IntEnum, unique
import random

from flask import Flask, Response
from datadog import DogStatsd
from pydantic.dataclasses import dataclass


@unique
class Sex(IntEnum):
    MALE = 0
    FEMALE = 1
    OTHER = 2


@dataclass
class Identity:
    description: str
    maleness: float
    femaleness: float

    @property
    def sex(self) -> Sex:
        if self.maleness >= 0.70:
            return Sex.MALE
        elif self.femaleness >= 0.70:
            return Sex.FEMALE
        else:
            return Sex.OTHER

    @property
    def genderness(self) -> float:
        return self.femaleness


@dataclass
class Config:
    identity: Identity
    metrics_host: str
    env_name: str
    hostname: str


class ConfigEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Config):
            skip_keys = ('__initialised__', 'identity', 'sex')
            main_dict = {k: v for k, v in obj.__dict__.items() if k not in skip_keys}
            main_dict['identity'] = {
                **{'sex': obj.identity.sex.name},
                **{k: v for k, v in obj.identity.__dict__.items() if k not in skip_keys}
            }
            return main_dict
        return json.JSONEncoder.default(self, obj)


id_descriptions = [line.rstrip('\n') for line in open('model_output.txt')]
classifiers = json.load(open('gender_classifier_output.json'))
rnd_i = random.randrange(0, len(id_descriptions))
config = Config(
    metrics_host=(os.getenv('METRICS_HOSTNAME', 'localhost')),
    env_name=os.environ['ENV_NAME'],
    hostname=os.environ['HOSTNAME'],
    identity=Identity(
        description=id_descriptions[rnd_i],
        femaleness=classifiers[rnd_i][0]['classification'][0]['p'],
        maleness=classifiers[rnd_i][0]['classification'][1]['p'],
    )
)

statsd = DogStatsd(host=config.metrics_host)
statsd.constant_tags = [
    f'sex:{config.identity.sex.name}',
    f'identity:{config.identity.description}',
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
    statsd.increment(metric='success', tags=[
        'method:GET',
        'function:get_config',
        f'status_code:{response.status_code}',
    ])
    statsd.gauge(metric='gender', value=config.identity.genderness)
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0')
