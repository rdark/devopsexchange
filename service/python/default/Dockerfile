FROM python:3.7.3-slim-stretch

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    dnsutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password \
            --disabled-login \
            --system \
            appuser

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY ./requirements.txt .
RUN pip install -r ./requirements.txt

COPY . /opt/app
# shouldn't be needed when running in a clean build env
RUN make clean

USER appuser

