#!/bin/bash

gcloud compute firewall-rules delete \
    default-allow-internal \
    default-allow-rdp \
    default-allow-icmp \
    default-allow-ssh \
    --quiet || true

gcloud compute networks delete default --quiet || true
