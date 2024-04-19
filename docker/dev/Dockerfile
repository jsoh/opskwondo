ARG TERRAFORM_VERSION=1.8.0
FROM hashicorp/terraform:${TERRAFORM_VERSION} as terraform-stage

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y bash bash-completion curl procps unzip wget && \
    rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c 'set -e && \
    ARCH=`uname -m` && \
    echo "$ARCH" && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-$ARCH.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install'

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser --shell /bin/bash

COPY .bash_profile /home/appuser/.bash_profile
COPY bashrc.d /home/appuser/.bashrc.d
RUN chmod +x /home/appuser/.bashrc.d/*.bashrc

RUN chown -R appuser:appgroup /app

COPY --from=terraform-stage /bin/terraform /usr/local/bin/terraform

USER appuser

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash", "--login"]
