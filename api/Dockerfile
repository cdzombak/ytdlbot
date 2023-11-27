ARG PROJECT_VERSION=<unknown>

FROM python:3.11-bullseye
ARG PROJECT_VERSION

RUN mkdir /app
COPY index.py /app
COPY requirements.txt /app

WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1
CMD ["python", "/app/index.py"]

LABEL license="GPL3"
LABEL maintainer="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.authors="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.url="https://github.com/cdzombak/ytdlbot"
LABEL org.opencontainers.image.documentation="https://github.com/cdzombak/ytdlbot/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/cdzombak/ytdlbot.git"
LABEL org.opencontainers.image.version="${PROJECT_VERSION}"
LABEL org.opencontainers.image.licenses="GPL3"
LABEL org.opencontainers.image.title="ytdlbot-api"
LABEL org.opencontainers.image.description="API for ytdlbot, an easy way to collect a video library from YouTube & other sites"
