if [ -d /mnt/c/users ]; then
  export TARGET_DIR=/mnt/c/data/mc/1
else
  export TARGET_DIR=/data/mc/1
fi
if [ ! -d $TARGET_DIR ]; then
  mkdir -p $TARGET_DIR
fi

curl -L https://api.papermc.io/v2/projects/paper/versions/1.21/builds/46/downloads/paper-1.21-46.jar --output $TARGET_DIR/paper-1.21-46.jar

if [ ! -e $TARGET_DIR/ops.json ]; then
  cp ops.json $TARGET_DIR/ops.json
fi
if [ ! -e $TARGET_DIR/server.properties ]; then
  cp server.properties $TARGET_DIR/server.properties
fi
if [ ! -e $TARGET_DIR/whitelist.json ]; then
  cp whitelist.json $TARGET_DIR/whitelist.json
fi