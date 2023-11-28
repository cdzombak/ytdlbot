ARG PROJECT_VERSION=<unknown>

FROM golang:1 AS golang-builder

WORKDIR /src
RUN git clone https://github.com/cdzombak/runner.git
WORKDIR /src/runner
RUN git fetch --tags && git checkout v2.8.4 && make build && ./out/runner -version

WORKDIR /src
RUN git clone https://github.com/cdzombak/dirshard.git
WORKDIR /src/dirshard
RUN git fetch --tags && git checkout v1 && make build && ./out/dirshard -version

FROM ubuntu:jammy
ARG PROJECT_VERSION

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install -yq \
       ca-certificates cron curl ffmpeg jq libcap2-bin python3 tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/cron.*/*

ENV PATH="/opt/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
RUN mkdir -p /opt/bin
COPY --from=golang-builder /src/runner/out/runner /opt/bin/runner
RUN chown root:root /opt/bin/runner && chmod 0755 /opt/bin/runner \
    && /opt/bin/runner -version
COPY --from=golang-builder /src/dirshard/out/dirshard /opt/bin/dirshard
RUN chown root:root /opt/bin/dirshard && chmod 0755 /opt/bin/dirshard \
    && /opt/bin/dirshard -version

RUN curl --silent -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod 0755 /usr/local/bin/yt-dlp

RUN groupadd -g 911 abc \
    && useradd -d / --no-log-init -u 911 -g 911 abc
RUN groupadd -g 995 netdata

COPY processor.sh /processor.sh
RUN chmod 0555 /processor.sh
COPY stats.sh /stats.sh
RUN chmod 0555 /stats.sh
COPY logfiles-cleanup.sh /logfiles-cleanup.sh
RUN chmod 0555 /logfiles-cleanup.sh

RUN mkdir -p /ytdlbot-logs
ENV RUNNER_LOG_DIR="/ytdlbot-logs"

COPY crontab.txt /etc/crontab
RUN chmod 0644 /etc/crontab

COPY healthcheck.sh /healthcheck.sh
RUN chmod 0555 /healthcheck.sh
HEALTHCHECK CMD /healthcheck.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0555 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# https://manpages.ubuntu.com/manpages/jammy/man8/cron.8.html
CMD ["cron", "-f", "-L", "7"]

LABEL license="GPL3"
LABEL maintainer="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.authors="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.url="https://github.com/cdzombak/ytdlbot"
LABEL org.opencontainers.image.documentation="https://github.com/cdzombak/ytdlbot/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/cdzombak/ytdlbot.git"
LABEL org.opencontainers.image.version="${PROJECT_VERSION}"
LABEL org.opencontainers.image.licenses="GPL3"
LABEL org.opencontainers.image.title="ytdlbot-processor"
LABEL org.opencontainers.image.description="Queue processor supporting ytdlbot, an easy way to collect a video library from YouTube & other sites"
