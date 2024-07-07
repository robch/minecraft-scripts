if [ -d /mnt/c/users ]; then
  export TARGET_DIR=/mnt/c/data/java17
else
  export TARGET_DIR=/data/java17
fi
if [ ! -d $TARGET_DIR ]; then
  mkdir -p $TARGET_DIR
fi

curl -L https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz --output OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz
tar -xvzf OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz -C $TARGET_DIR
