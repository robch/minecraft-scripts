if [ -d /mnt/c/users ]; then
  export DATA_DIR=/mnt/c/data
else
  export DATA_DIR=/data
fi

cd $DATA_DIR/mc/2
# set JAVA_HOME=$DATA_DIR/java17/jdk-17.0.1+12
# $DATA_DIR/java17/jdk-17.0.1+12/bin/java  -Dlog4j2.formatMsgNoLookups=true -Xms4G -Xmx4G -jar paper-1.21-46.jar
java -Xms4G -Xmx4G -jar paper-1.21-46.jar