FROM jupyter/pyspark-notebook

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


COPY generate-jupyter-hashed-password.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-jupyter-hashed-password.sh

RUN groupadd -g 1000 stacklabs
RUN usermod -a -G sudo jovyan
RUN echo 'jovyan ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN apt-get install python-pip -y
USER jovyan

RUN git clone https://github.com/xmavrck/jupyter-lessons.git /home/jovyan/work/stacklabs

#RUN sudo pip2 install --upgrade pip && \
#    sudo python2 -m pip install ipykernel && \
#    sudo python2 -m ipykernel install --user
CMD ["/usr/local/bin/generate-jupyter-hashed-password.sh"]
