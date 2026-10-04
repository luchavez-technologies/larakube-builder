# Builder for `larakube django:new`: Python with Django already installed.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PIP_PACKAGES

RUN pip install --no-cache-dir ${PIP_PACKAGES}
