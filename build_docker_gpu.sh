#!/usr/bin/env bash
nvidia-docker build -f ./Dockerfile.gpu -t dev/gpu:1.0 .
