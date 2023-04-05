FROM centos:7

ENV DAEMON_RUN=true
ENV SCALA_HOME=/usr/share/scala
ENV SPARK_HOME=/usr/share/spark

ADD ./bootstrap.sh /tmp/

RUN /tmp/bootstrap.sh

ENTRYPOINT ["/bin/bash"]