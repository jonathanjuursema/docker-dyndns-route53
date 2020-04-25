FROM amazon/aws-cli:latest

COPY ./update.sh /update.sh

ENTRYPOINT /update.sh
