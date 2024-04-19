FROM node:21-slim

WORKDIR /app

COPY monitor.sh /app/

RUN chmod +x /app/monitor.sh

RUN apt update && apt install git inotify-tools -y
RUN npm install -g serve

EXPOSE 3000

CMD ["/app/monitor.sh"]

