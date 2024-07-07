if [ -d /mnt/c/users ]; then
  export TARGET_DIR=/mnt/c/data/java21
else
  export TARGET_DIR=/data/java21
fi
if [ ! -d $TARGET_DIR ]; then
  mkdir -p $TARGET_DIR
fi

curl -L https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.3_9.tar.gz --output OpenJDK21U-jdk_x64_linux_hotspot_21.0.3_9.tar.gz
tar -xvzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.3_9.tar.gz -C $TARGET_DIR
