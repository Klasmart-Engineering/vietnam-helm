FROM debian:bullseye-slim

ARG NS_KIDSLOOP

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

COPY make_secret_ecr_vn.sh .
RUN chmod +x make_secret_ecr_vn.sh

ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "./make_secret_ecr_vn.sh", "$NS_KIDSLOOP" ]

