#!/usr/bin/env bash
nvidia-docker build -f ./Dockerfile.gpu --build-arg cuda_version=9.0 --build-arg cuda_version=7 -t dev/gpu:1.0 .
