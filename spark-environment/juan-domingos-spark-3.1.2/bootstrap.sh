#!/bin/bash

export SPARK_VERSION=3.1.2
export HADOOP_VERSION=3.2
export COMPLETE_HADOOP_VERSION=3.2.2
export SCALA_VERSION=2.12.14
export SCALA_HOME=/opt/scala
export SPARK_HOME=/opt/spark
export HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}

prepare_envitonment() {
    mkdir -p /tmp/
    yum update -y
    yum install wget -y
}

install_jdk8() {
    echo "Starting JDK 8 installation ..."
    yum install java-1.8.0-openjdk -y
    echo "Finishing JDK 8 installation ..."
}

install_scala() {
    echo "Starting scala environment setup ..."
    cd /tmp/ 

    echo "Downloading scala sources ..."
    wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz

    tar xzf "scala-${SCALA_VERSION}.tgz"

    echo "Creating scala home directory ..."
    mkdir -p ${SCALA_HOME}/

    echo "Removing scala scripting files ..."
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat

    echo "Moving scala sources to scala home"
    mv "/tmp/scala-${SCALA_VERSION}/"* "${SCALA_HOME}"
    
    echo "Creating scala binaries reference on shared user binaries"
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/"

    echo "Cleaning scala source files from tmp ..."
    rm -rf "/tmp/scala-${SCALA_VERSION}"
    rm -rf "/tmp/scala-${SCALA_VERSION}.tgz"

    echo "Scala Setup was finished with success."
}

install_scala_build_tools() {
    echo "Starting sbt installation ..."

    echo "Removing oldest binaries sources ..."
    rm -f /etc/yum.repos.d/bintray-rpm.repo
    
    echo "Getting sources location on repository ..."
    curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo
    
    echo "Adding repo references ..."
    mv sbt-rpm.repo /etc/yum.repos.d/
   
    echo "Installing scala build tools"
    yum install sbt -y

    echo "Scala build tools was installed with success ..."
}

install_apache_spark() {
    echo "Starting apache spark installation ..."
    
    cd /tmp/

    echo "Downloading spark sources ..."
    wget https://ftp.unicamp.br/pub/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

    mkdir -p ${SPARK_HOME}/

    echo "Uncompressing spark sources ..."
    tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

    echo "Moving spark sources to spark home ..."
    mv "/tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/"* "${SPARK_HOME}"

    echo "Cleaning spark source files from tmp ..."
    rm -rf "/tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
    rm -rf "/tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" 

    echo "Removing spark sources from temporary folder ..."
}

install_hadoop() {
    echo "Starting Hadoop Installation ..."

    cd /tmp/

    mkdir -p $HADOOP_HOME

    echo "Downloading Hadoop Sources ..."
    wget https://mirror.nbtelecom.com.br/apache/hadoop/common/hadoop-${COMPLETE_HADOOP_VERSION}/hadoop-${COMPLETE_HADOOP_VERSION}.tar.gz

    echo "Downloading Hadoop Checksum"
    wget https://downloads.apache.org/hadoop/common/hadoop-${COMPLETE_HADOOP_VERSION}/hadoop-${COMPLETE_HADOOP_VERSION}.tar.gz.sha512


    echo "Installing perl checksum validator"
    yum install -y perl-Digest-SHA

    shasum -a 512 hadoop-${COMPLETE_HADOOP_VERSION}.tar.gz >> file_check_sum.txt

    FILE_CHECKSUM=$(cat file_check_sum.txt)
    HOST_CHECKSUM=$(cat hadoop-${COMPLETE_HADOOP_VERSION}.tar.gz.sha512)

    if [ "$FILE_CHECKSUM"="$HOST_CHECKSUM" ]; then

        echo "Uncopressing hadoop binary sources ..." 
        tar xzf hadoop-${COMPLETE_HADOOP_VERSION}.tar.gz

        echo "Moving Hadoop Sources to HADOOP_HOME"
        mv "./hadoop-${COMPLETE_HADOOP_VERSION}"/* "${HADOOP_HOME}"/

    else
      echo "Hadoop installation was finished with fail because the sources checksum is not right"
    fi
}

setup_path() {
    echo "export SPARK_VERSION=${SPARK_VERSION}" >> ~/.bash_profile
    echo "export HADOOP_VERSION=${HADOOP_VERSION}" >> ~/.bash_profile
    echo "export SCALA_VERSION=${SCALA_VERSION}" >> ~/.bash_profile
    echo "export SCALA_HOME=${SCALA_HOME}" >> ~/.bash_profile
    echo "export SPARK_HOME=${SPARK_HOME}" >> ~/.bash_profile
    echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> ~/.bash_profile
    echo "export HADOOP_HOME=${HADOOP_HOME}" >> ~/.bash_profile
    echo "export PATH=\$SCALA_HOME/bin/:\$SPARK_HOME/bin/:\$JAVA_HOME/bin/:\$HADOOP_HOME/bin/:${PATH}" >> ~/.bash_profile
}

prepare_envitonment
install_jdk8
install_scala
install_scala_build_tools
install_apache_spark
install_hadoop
setup_path