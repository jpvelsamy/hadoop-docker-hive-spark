#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${HIVE_PREFIX:=/usr/local/hive}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/HOSTNAME/$HOSTNAME/ /usr/local/spark/yarn-remote-client/core-site.xml > /usr/local/spark/yarn-remote-client/core-site.xml
sed s/HOSTNAME/$HOSTNAME/ /usr/local/spark/yarn-remote-client/yarn-site.xml > /usr/local/spark/yarn-remote-client/yarn-site.xml

echo spark.yarn.jar hdfs:///spark/spark-assembly-2.0.2-hadoop2.7.3.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
