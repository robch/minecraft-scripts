#!/bin/bash

# This script will return the user name for the Minecraft server.
#
# USAGE:    bash -get-mc-user-name.sh
# EXAMPLE:  bash -get-mc-user-name.sh
# PRE-REQS: none
#

# defaults used across all scripts
MC_DEFAULT_WORLD=World1
MC_FQ_DIR_ON_WSL=/mnt/c/data/mc
MC_FQ_DIR_ON_LINUX=/data/

# ensure dependencies are installed
mc_check_dependencies() {
  if [ ! -x "$(command -v jq)" ]; then
    echo "jq is not installed. Please install it."
    exit 1
  fi
}

# get the service "slot" or the default
mc_get_slot_or_default() {
  if [ -z "$1" ]; then
    echo 1
  else
    echo $1
  fi
}

# get the user name for the Minecraft server
mc_get_user_name() {
  # whoami
  echo "root"
}

# get the base mc directory
mc_get_fq_dir() {
  if [ -d /mnt/c/users ]; then
    echo $MC_FQ_DIR_ON_WSL
  else
    echo $MC_FQ_DIR_ON_LINUX
  fi
}

# get the base mc worlds directory
mc_get_worlds_fq_dir() {
  echo "$(mc_get_fq_dir)/worlds"
}

# get the world basename for the specified world
# param1: the world name, if not set, use the default
mc_get_world_basename_or_default() {
  if [ -z "$1" ]; then
    echo $MC_DEFAULT_WORLD
  else
    echo $1
  fi
}

# get the world directory for the specified world
# param1: the world name, if not set, use the default
mc_get_world_fq_dir() {
  MC_WORLD=$(mc_get_world_basename_or_default $1)
  echo "$(mc_get_worlds_fq_dir)/$MC_WORLD"
}

# get the the world description fq filename for the specified world
# param1: the world name, if not set, use the default
mc_get_world_description_fq_filename() {
  echo "$(mc_get_world_fq_dir $1)/world-description.txt"
}

# get the world description for the specified world
# param1: the world name, if not set, use the default
mc_get_world_description() {
  WORLD=$(mc_get_world_basename_or_default $1)
  DESCRIPTION_FILE=$(mc_get_world_description_fq_filename $WORLD)
  if [ ! -f $DESCRIPTION_FILE ]; then
    echo $WORLD
  else
    cat $DESCRIPTION_FILE
  fi
}

# set the world description for the specified world
# param1: if one arguments: the world description
# param1: if two arguments: the world name
# param2: if two arguments: the world description
mc_set_world_description() {

  # if arg 1 and 2 are both present (use and operator)
  if [ -n "$1" ] && [ -n "$2" ]; then
    WORLD=$1
    DESCRIPTION=$2
  elif [ -n "$1" ]; then
    WORLD=$MC_DEFAULT_WORLD
    DESCRIPTION=$1
  else
    WORLD=$(mc_get_world_basename_or_default $1)
    DESCRIPTION=$WORLD
  fi

  DESCRIPTION_FILE=$(mc_get_world_description_fq_filename $WORLD)
  mc_ensure_dir_exists $(dirname $DESCRIPTION_FILE)

  echo $DESCRIPTION > $DESCRIPTION_FILE
  cat $DESCRIPTION_FILE
}

# get the worlds that have names
mc_get_worlds() {
  WORLDS_FQ_DIR=$(mc_get_worlds_fq_dir)
  if [ -d $WORLDS_FQ_DIR ]; then
    WORLDS=$(find $(mc_get_worlds_fq_dir) -type f -name "world-description.txt")
    if [ ! -z "$WORLDS" ]; then
      for WORLD in $WORLDS; do
        echo "$(basename $(dirname $WORLD))"
      done
    fi
  fi
}

# get the worlds in "json" format
mc_get_worlds_json() {
  WORLDS=$(mc_get_worlds)
  if [ ! -z "$WORLDS" ]; then
    echo "["
    FIRST=true
    for WORLD in $WORLDS; do
      DESCRIPTION=$(mc_get_world_description $WORLD)
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        echo ","
      fi
      echo "  {"
      echo "    \"Name\": \"$WORLD\","
      echo "    \"Description\": \"$DESCRIPTION\"",
      echo "    \"Directory\": \"$(mc_get_world_fq_dir $WORLD)\""
      echo "  }"
    done
    echo "]"
  fi
}
# get the world's paper-server.jar fq filename
# param1: the world name, if not set, use the default
mc_get_world_paper_server_jar_fq_filename() {
  echo "$(mc_get_world_fq_dir $1)/paper-server.jar"
}

# get the latest paper version
mc_get_latest_paper_version() {
  PAPER_API="https://papermc.io/api/v2/projects/paper"
  PAPER_VERSION=$(curl -s $PAPER_API | jq '.versions | last')
  echo $PAPER_VERSION | tr -d '"'
}

# get the paper version
# param1: the version to use, if not set, use the latest
mc_get_paper_version_or_latest() {
  if [ -z "$1" ]; then
    echo $(mc_get_latest_paper_version)
  else
    echo $1
  fi
}

# get the latest paper build
# param1: the paper version to use, if not set, use the latest
mc_get_paper_build_or_latest() {
  PAPER_VERSION=$(mc_get_paper_version_or_latest $1)
  PAPER_API="https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION/builds"

  # get the last build's build number
  curl -s $PAPER_API | jq '.builds | last | .build'
}

# get the paper build
# param1: the paper version to use, if not set, use the default
# param2: the paper build to use, if not set, use the default
mc_get_paper_build() {
  if [ -z "$2" ]; then
    PAPER_VERSION=$(mc_get_paper_version_or_latest $1)
    PAPER_BUILD=$(mc_get_paper_build_or_latest $PAPER_VERSION)
    echo $PAPER_BUILD
  else
    echo $2
  fi
}

# get the paper jar URL
# param1: the paper version to use, if not set, use the default
# param2: the paper build to use, if not set, use the default
mc_get_paper_jar_url() {
  PAPER_VERSION=$(mc_get_paper_version_or_latest $1)
  PAPER_BUILD=$(mc_get_paper_build $1 $2)
  echo "https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar"
}

# ensure a directory exists
# param1: the directory to check
mc_ensure_dir_exists() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

# download and install the Microsoft OpenJDK 21
mc_download_and_install_openjdk() {
  UBUNTU_RELEASE=`lsb_release -rs`
  wget https://packages.microsoft.com/config/ubuntu/${UBUNTU_RELEASE}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb

  # install the Microsoft OpenJDK 21
  sudo apt-get install apt-transport-https
  sudo apt-get update
  sudo apt-get install msopenjdk-21

  # set the default Java version to Microsoft OpenJDK 21
  sudo update-java-alternatives --set msopenjdk-21-amd64

  # check to make sure it is installed
  VERSION=$(java --version)

  # Check that the default Java version is Microsoft OpenJDK 21
  if [[ $VERSION == *"OpenJDK"* && $VERSION == *"64-Bit"* && $VERSION == *"Microsoft"* && $VERSION == *"21"* ]]; then
    echo -e "\e[32mMicrosoft OpenJDK 21 installed successfully.\e[0m"
  else
    echo -e "\e[31mMicrosoft OpenJDK 21 did not install successfully.\e[0m"
    exit 1
  fi
}

# download the paper jar file
# param1: the world name, if not set, use the default
# param2: the paper version to use, if not set, use the default
# param3: the paper build to use, if not set, use the default
mc_download_paper_server_jar() {
  WORLD=$(mc_get_world_basename_or_default $1)
  JAR_FQ_FILE=$(mc_get_world_paper_server_jar_fq_filename $WORLD)
  JAR_URL=$(mc_get_paper_jar_url $2 $3)

  # download the PaperMC server jar file
  echo "Downloading PaperMC"
  echo
  echo "  FROM: $JAR_URL"
  echo "    TO: $JAR_FQ_FILE"
  echo

  mc_ensure_dir_exists $(dirname $JAR_FQ_FILE)
  curl -J -L $JAR_URL -o $JAR_FQ_FILE

  # check to make sure it's at least 1 mega byte
  if [ $(stat -c%s $JAR_FQ_FILE) -lt 1000000 ]; then
    echo -e "\e[31mDownload failed. File is too small.\e[0m"
    echo -e "\e[31mCheck the version and build number and try again.\e[0m"
    echo -e "\e[31mCheck https://papermc.io/downloads/paper for the latest version and build number.\e[0m"
    exit 1
  fi

  # show success message
  LS_FILE=$(ls -l $JAR_FQ_FILE)
  echo 
  echo -e "\e[32m**************\e[0m"
  echo -e "\e[32m* DOWNLOADED *   $LS_FILE\e[0m"
  echo -e "\e[32m**************\e[0m"
  echo 
}

# accept the eula for the specified world
# param1: the world name, if not set, use the default
mc_accept_eula() {
  WORLD=$(mc_get_world_basename_or_default $1)
  WORLD_FQ_DIR=$(mc_get_world_fq_dir $WORLD)

  # change to the world directory
  mc_ensure_dir_exists $WORLD_FQ_DIR
  cd $WORLD_FQ_DIR

  # if there is no eula.txt file, create one
  if [ ! -f eula.txt ]; then
    echo "eula=false" > eula.txt
  fi

  # replace the eula=false with eula=true
  sed -i 's/eula=false/eula=true/g' eula.txt

  # verify the eula.txt file
  EULA_CONTENTS=$(cat eula.txt)
  if [[ $EULA_CONTENTS == *"eula=true"* ]]; then
    echo -e "\e[32mEULA accepted for $WORLD.\e[0m"
  else
    echo -e "\e[31mEULA not accepted.\e[0m"
    exit 1
  fi
}

# get the service file content for the specified world and slot
# param1: the world name, if not set, use the default
# param2: the slot number, if not set, use the default
mc_get_world_service_file_content() {
  WORLD=$(mc_get_world_basename_or_default $1)
  SERVER_SLOT=$(mc_get_slot_or_default $2)

  JAVA_DIR=$(dirname $(which java))
  JAR_FQ_FILE=$(mc_get_world_paper_server_jar_fq_filename $WORLD)
  WORLD_FQ_DIR=$(mc_get_world_fq_dir $WORLD)
  MC_USER=$(mc_get_user_name)

  _=$(mc_set_world_description $WORLD)

  # output the service file
  echo "# minecraft.service"
  echo ""
  echo "[Unit]"
  echo "Description=minecraft-slot-$SERVER_SLOT.service"
  echo "After=network.target"
  echo ""
  echo "[Service]"
  echo "ExecStart=$JAVA_DIR/java -Xms4G -Xmx4G -jar $JAR_FQ_FILE"
  echo "WorkingDirectory=$WORLD_FQ_DIR"
  echo "Restart=always"
  echo "RestartSec=10"
  echo "User=$MC_USER"
  echo ""
  echo "[Install]"
  echo "WantedBy=multi-user.target"
}

# get the service file name for the specified slot
# param1: the slot number, if not set, use the default
mc_get_service_base_file_name() {
  echo "minecraft-slot-$(mc_get_slot_or_default $1).service"
}

# create the service file for the specified world and slot
# param1: the world name, if not set, use the default
# param2: the slot number, if not set, use the default
mc_create_world_service_file() {
  TEMP_FILE_NAME=temp-file.service

  # create a temp version of the service file
  SERVICE_FILE_CONTENT=$(mc_get_world_service_file_content $1 $2)
  echo "$SERVICE_FILE_CONTENT" > $TEMP_FILE_NAME

  # copy the temp file to the service file
  SERVER_SLOT=$(mc_get_slot_or_default $2)
  SERVICE_FILE_NAME=$(mc_get_service_base_file_name $2)
  sudo cp $TEMP_FILE_NAME /etc/systemd/system/$SERVICE_FILE_NAME
  rm $TEMP_FILE_NAME

  echo /etc/systemd/system/$SERVICE_FILE_NAME
}

# quick test of some of the core functions
mc_test1() {
  DO_VERSION_STUFF=false
  DO_NON_VERSION_STUFF=false
  if [ -z "$1" ]; then
    DO_VERSION_STUFF=true
    DO_NON_VERSION_STUFF=true
  elif [[ $1 == 1.* ]]; then
    DO_VERSION_STUFF=true
  else
    DO_NON_VERSION_STUFF=true
  fi

  if [ "$DO_NON_VERSION_STUFF" = true ]; then
    echo mc_get_user_name=$(mc_get_user_name)
    echo mc_get_fq_dir=$(mc_get_fq_dir $1 $2 $3)
    echo mc_get_worlds_fq_dir=$(mc_get_worlds_fq_dir $1 $2 $3)
    echo mc_get_world_fq_dir=$(mc_get_world_fq_dir $1 $2 $3)
    echo mc_get_world_description_fq_filename=$(mc_get_world_description_fq_filename $1 $2 $3)
    echo mc_get_world_paper_server_jar_fq_filename=$(mc_get_world_paper_server_jar_fq_filename $1 $2 $3)
  fi

  if [ "$DO_VERSION_STUFF" = true ]; then
    echo mc_get_latest_paper_version=$(mc_get_latest_paper_version $1 $2 $3)
    echo mc_get_paper_version_or_latest=$(mc_get_paper_version_or_latest $1 $2 $3)
    echo mc_get_paper_build_or_latest=$(mc_get_paper_build_or_latest $1 $2 $3)
    echo mc_get_paper_build=$(mc_get_paper_build $1 $2 $3)
    echo mc_get_paper_jar_url=$(mc_get_paper_jar_url $1 $2 $3)
  fi
}
