FROM java:7


#MAINTAINER Wellington Marinho wpmarinho@globo.com
MAINTAINER gamesmod

# Init ENV
ENV BISERVER_VERSION 9.1
ENV BISERVER_TAG 9.1.0.0-324

ENV PENTAHO_HOME /opt/pentaho

# Apply JAVA_HOME
RUN . /etc/environment
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64

# Install Dependences
RUN apt-get update; apt-get install zip netcat -y; \
    apt-get install wget unzip git postgresql-client-9.4 vim -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    curl -O https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    pip install awscli; \
    rm -f get-pip.py

RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

# Download Pentaho BI Server
RUN /usr/bin/wget --progress=dot:giga https://sourceforge.net/projects/pentaho/files/Pentaho%209.1${BISERVER_VERSION}/serever/pentaho-server-ce-${BISERVER_TAG}.zip -O /tmp/biserver-ce-${BISERVER_TAG}.zip; \
    /usr/bin/unzip -q /tmp/biserver-ce-${BISERVER_TAG}.zip -d  $PENTAHO_HOME; \
    rm -f /tmp/pentaho-server-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/biserver-ce/promptuser.sh; \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/biserver-ce/tomcat/bin/startup.sh; \
    chmod +x $PENTAHO_HOME/biserver-ce/start-pentaho.sh

COPY config $PENTAHO_HOME/config
COPY scripts $PENTAHO_HOME/scripts

WORKDIR /opt/pentaho 
EXPOSE 8080 
CMD ["sh", "scripts/run.sh"]
