FROM python:3.10-slim-bullseye
RUN apt-get update; apt-get -y upgrade; apt-get clean
RUN apt-get install binutils -y

# Default port
ENV PORT=9333

RUN pip3 install PyInstaller loguru prometheus_client PyP100 click pyyaml

COPY . /app
WORKDIR /app

RUN python3 -m PyInstaller main.py --onefile --hidden-import loguru --hidden-import prometheus_client --hidden-import PyP100

EXPOSE $PORT
CMD /app/dist/main --tapo-email=$TAPO_EMAIL --tapo-password=$TAPO_PASSWORD --config-file=/app/tapo.yaml --prometheus-port=$PORT