FROM public.ecr.aws/docker/library/alpine:3.21.3

# renovate: datasource=github-releases depName=Kozea/Radicale
ENV VERSION=v3.5.1

ENV \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PIP_ROOT_USER_ACTION=ignore \
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  CRYPTOGRAPHY_DONT_BUILD_RUST=1

ENV RADICALE_CONFIG_FILE=/config/config

LABEL org.opencontainers.image.source="https://github.com/Kozea/Radicale"

COPY ./config.default /app/config.default

#hadolint ignore=DL3018,DL3013
RUN \
  apk add --no-cache --virtual=build-dependencies \
  gcc \
  musl-dev \
  libffi-dev \
  python3-dev \
  && apk add --no-cache \
  ca-certificates \
  python3 \
  py3-pip \
  py3-tz \
  tzdata \
  git \
  && python3 -m pip install --upgrade --break-system-packages pip \
  && python3 -m pip install "git+https://github.com/Kozea/Radicale@$VERSION" --break-system-packages passlib[bcrypt] \
  && addgroup -S radicale --gid 568 \
  && adduser -S radicale -G radicale --uid 568 \
  && chown -R 568:568 /app \
  && chmod -R 755 /app \
  && mkdir -p /config \
  && chown -R radicale:radicale /config \
  && chmod -R 775 /config \
  && mkdir -p /data \
  && chown -R radicale:radicale /data \
  && chmod -R 775 /data \
  && apk del --purge build-dependencies \
  && rm -rf \
  /root/.cache \
  /root/.cargo \
  /tmp/*

USER radicale
COPY ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]