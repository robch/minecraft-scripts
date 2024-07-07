if [ -d /mnt/c/users ]; then
  export DATA_DIR=/mnt/c/data
else
  export DATA_DIR=/data
fi

cd $DATA_DIR/mc/2
export JAVA_HOME=$DATA_DIR/java21/jdk-21.0.3+9
export PATH=$JAVA_HOME/bin:$PATH
java --version
$JAVA_HOME/bin/java  -Dlog4j2.formatMsgNoLookups=true -Xms4G -Xmx4G -jar paper-1.21-46.jar