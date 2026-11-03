#!/usr/bin/env bash
# Imperative deployment: a list of steps. Running it twice may fail or
# change nothing, and it says nothing about what should exist afterwards.
set -e
kubectl create namespace starfleet-staging
kubectl -n starfleet-staging create deployment scout --image=ghcr.io/stefanprodan/podinfo:6.15.0
kubectl -n starfleet-staging scale deployment scout --replicas=1
kubectl -n starfleet-staging expose deployment scout --port=80 --target-port=9898
