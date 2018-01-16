#!/usr/bin/env bash
nvidia-docker build -f ./Dockerfile.gpu --build-arg cuda_version=8.0 --build-arg cuda_version=5 -t dev/gpu:1.0 .
