FROM python:3.10.4-bullseye
MAINTAINER MRR

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y netcat-openbsd gcc && \
    apt-get install -y libpq-dev && \
    apt-get clean



COPY ./qrtick /usr/src/qrtick
COPY ./requirements.txt /usr/src/qrtick
COPY ./scripts /scripts

WORKDIR /usr/src/qrtick
RUN pip install --upgrade pip
RUN pip install -r requirements.txt


RUN mkdir -p /vol/web/media
RUN mkdir -p /vol/web/static


RUN adduser --disabled-password --no-create-home --gecos '' app
RUN chown -R app:app /vol
RUN chmod -R 755 /vol
RUN chmod -R +x /scripts

ENV PATH="/scripts:$PATH"
USER app
EXPOSE 8000

#CMD ["run.sh"]

