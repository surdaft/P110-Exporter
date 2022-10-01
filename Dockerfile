FROM python:3.10-slim-bullseye
RUN apt-get update; apt-get -y upgrade; apt-get clean
RUN apt-get install binutils -y

# Default port
ENV PORT=9333

RUN pip3 install PyInstaller loguru prometheus_client PyP100 click pyyaml

# APPLYING UNMERGED FIX for https://github.com/fishbigger/TapoP100/issues/76  TEMP
RUN apt install git -y
RUN git clone https://github.com/tking2/TapoP100.git
WORKDIR /TapoP100
RUN git format-patch -1 132ae9b4893584a023be69ae497560a928b1c24e
RUN git format-patch HEAD~
RUN git apply -p2 --unsafe-paths --ignore-space-change --ignore-whitespace --directory='/usr/local/lib/python3.10/site-packages/PyP100' 0001-fix-Improve-parsing-of-cookie-thus-removing-trailing.patch 
RUN git apply -p2 --unsafe-paths --ignore-space-change --ignore-whitespace --directory='/usr/local/lib/python3.10/site-packages/PyP100' 0001-chg-Pre-emptively-move-to-using-cookies.patch
# END OF FIX

COPY . /app
WORKDIR /app

RUN python3 -m PyInstaller main.py --onefile --hidden-import loguru --hidden-import prometheus_client --hidden-import PyP100

EXPOSE $PORT
CMD /app/dist/main --tapo-email=$TAPO_EMAIL --tapo-password=$TAPO_PASSWORD --config-file=/app/tapo.yaml --prometheus-port=$PORT