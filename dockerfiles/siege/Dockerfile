FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    siege \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password \
            --disabled-login \
            --system \
            appuser

USER appuser

ENTRYPOINT ["siege"]
CMD ["--help"]
