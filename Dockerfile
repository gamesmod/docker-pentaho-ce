FROM openjdk:8

LABEL maintainer=gamesmod image=pentaho-server-ce


# Init ENV
ENV BISERVER_VERSION 9.3
ENV BISERVER_TAG 9.3.0.0-428


ENV PENTAHO_HOME /opt/pentaho

ENV KETTLE_HOME $PENTAHO_HOME/data-integration
ENV PENTAHO_DI_JAVA_OPTIONS "-Xms1024m -Xmx2048m -XX:+UseParallelGC -XX:ParallelGCThreads=4"

# Apply JAVA_HOME
RUN . /etc/environment
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64

# Install Dependences
RUN apt-get update -y; apt-get install zip netcat -y; \
    apt-get install wget unzip git postgresql-client vim -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    curl -O https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    pip install awscli; \
    rm -f get-pip.py

RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown pentaho:pentaho ${PENTAHO_HOME}

USER pentaho
# Download Pentaho DI

RUN wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Pentaho-${BISERVER_VERSION}/client-tools/pdi-ce-${BISERVER_TAG}.zip -O /tmp/pdi-ce-${BISERVER_TAG}.zip; \
	unzip -q /tmp/pdi-ce-${BISERVER_TAG}.zip -d  $PENTAHO_HOME; \
	rm -f /tmp/pdi-ce-${BISERVER_TAG}.zip

# Download Pentaho BI Server
RUN /usr/bin/wget --progress=dot:giga https://sourceforge.net/projects/pentaho/files/Pentaho-${BISERVER_VERSION}/server/pentaho-server-ce-${BISERVER_TAG}.zip -O /tmp/pentaho-server-ce-${BISERVER_TAG}.zip; \
    /usr/bin/unzip -q /tmp/pentaho-server-ce-${BISERVER_TAG}.zip -d  $PENTAHO_HOME; \
    rm -f /tmp/pentaho-server-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/pentaho-server/promptuser.sh; \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/pentaho-server/tomcat/bin/startup.sh; \
    chmod +x $PENTAHO_HOME/pentaho-server/start-pentaho.sh

COPY config $PENTAHO_HOME/config
COPY scripts $PENTAHO_HOME/scripts

#Carte config file
COPY master.xml /home/pentaho/data-integration

WORKDIR /opt/pentaho 
EXPOSE 8080 
CMD ["sh", "scripts/run.sh"]
