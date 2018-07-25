FROM jupyter/pyspark-notebook

RUN pip install tensorflow==1.3.0

RUN pip install keras

RUN cd /usr/local/spark && wget http://central.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-8_2.11/2.2.0/spark-streaming-kafka-0-8_2.11-2.2.0.jar

USER root
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    vim \
    nano \
    wget \
    net-tools \
    netcat \
    curl \
    git

RUN groupadd -g 1000 xtendlabs
RUN usermod -a -G sudo jovyan
RUN echo 'jovyan ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN apt-get install python-pip -y
USER jovyan
RUN sudo pip2 install --upgrade pip && \
    sudo python2 -m pip install ipykernel && \
    sudo python2 -m ipykernel install --user
