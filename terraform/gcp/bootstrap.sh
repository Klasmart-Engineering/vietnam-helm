#!/bin/bash
set -e

gcloud services enable \
  servicenetworking.googleapis.com \
  servicemanagement.googleapis.com \
  iamcredentials.googleapis.com \
  cloudkms.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  redis.googleapis.com \
  sqladmin.googleapis.com