FROM alpine:3.5

RUN apk add --update-cache py3-pip ca-certificates py3-certifi py3-lxml\
                           python3-dev cython cython-dev libusb-dev build-base \
                           eudev-dev linux-headers libffi-dev openssl-dev \
                           jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev \
                           tiff-dev tk-dev tcl-dev

COPY setup.py README.rst requirements.txt /build/
RUN pip3 install -r /build/requirements.txt

COPY aws_google_auth /build/aws_google_auth
RUN pip3 install -e /build/[u2f]

ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENTRYPOINT ["aws-google-auth"]

############################################################################
### for playwright install
FROM python:3-slim-bullseye as playwright
COPY setup.py README.rst requirements-playwright.txt /build/

RUN python3 -m venv /build/venv
RUN . /build/venv/bin/activate \
    && pip3 install -r /build/requirements-playwright.txt \
    && playwright install --with-deps chromium

COPY aws_google_auth /build/aws_google_auth
RUN . /build/venv/bin/activate && pip3 install -e /build/[u2f]

RUN ln -s /build/venv/bin/aws-google-auth /usr/local/bin/aws-google-auth
RUN ln -s /build/venv/bin/login-playwright /usr/local/bin/login-playwright
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["aws-google-auth"]
############################################################################
