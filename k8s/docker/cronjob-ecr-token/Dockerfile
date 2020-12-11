FROM debian:bullseye-slim

RUN apt update && \
    apt install --no-install-recommends -y \
      jq    \
      curl  \
      unzip \
      groff \
    && \
    rm -rf /var/lib/apt/lists/* && \
    curl -kL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip "awscliv2.zip" && \
    ./aws/install && \
    curl -kLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -ks https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin

COPY ../../bootstrap/make_secret_ecr.sh .
RUN chmod +x make_secret.sh

ENTRYPOINT [ "/bin/sh", "-c" ]

CMD [ "./make_secret_ecr.sh" ]

