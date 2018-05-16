FROM confluentinc/cp-kafka-connect:4.1.0-1
RUN apt update
RUN apt install net-tools htop slurm tcptrack curl -y
COPY ./kafka-connect-syslog-0.2.16/usr/share/kafka-connect/kafka-connect-syslog/* /etc/kafka-connect/jars/
EXPOSE 514
WORKDIR /root/
