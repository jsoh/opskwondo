FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y bash bash-completion curl procps unzip wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser --shell /bin/bash

COPY .bash_profile /home/appuser/.bash_profile
COPY bashrc.d /home/appuser/.bashrc.d
RUN chmod +x /home/appuser/.bashrc.d/*.bashrc

RUN chown -R appuser:appgroup /app

USER appuser

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash", "--login"]
