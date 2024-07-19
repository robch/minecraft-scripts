if [ -d /mnt/c/users ]; then
  export DATA_DIR=/mnt/c/data
else
  export DATA_DIR=/data
fi

cd $DATA_DIR/mc/1
export JAVA_HOME=$DATA_DIR/java21/jdk-21.0.3+9
export PATH=$JAVA_HOME/bin:$PATH
java --version
$JAVA_HOME/bin/java -Xms4G -Xmx4G -jar paper-1.21-60.jar --nogui