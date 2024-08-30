#!/bin/bash

# defaults used across all scripts
MC_DEFAULT_WORLD=World1
MC_FQ_DIR_ON_WSL=/mnt/c/data/mc
MC_FQ_DIR_ON_LINUX=/data/

# Function: mc_global_download_and_install_openjdk_21
# Description: Download and install the Microsoft OpenJDK 21
# Parameters: None
#
mc_global_download_and_install_openjdk_21() {
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

# Function: mc_global_dependencies_check
# Description: Check to make sure all dependencies are installed
# Parameters: None
#
mc_global_dependencies_check() {
  if [ ! -x "$(command -v jq)" ]; then
    echo "jq is not installed. Please install it."
    exit 1
  fi
  echo "All dependencies are installed."
}

# Function: mc_global_ensure_dir_exists
# Description: Ensure a directory exists
# Parameters:
# - $1: the directory to check
#
mc_global_ensure_dir_exists() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

# Function: mc_global_fq_dir_get
# Description: Get the base Minecraft directory
# Parameters: None
#
mc_global_fq_dir_get() {
  if [ -d /mnt/c/users ]; then
    echo $MC_FQ_DIR_ON_WSL
  else
    echo $MC_FQ_DIR_ON_LINUX
  fi
}

# Function: mc_global_fq_scripts_dir_get
# Description: Get the base Minecraft scripts directory
# Parameters: None
#
mc_global_fq_scripts_dir_get() {
  echo $(dirname $0)
}

# Function: mc_global_fq_default_files_dir_get
# Description: Get the base Minecraft default files directory
# Parameters: None
#
mc_global_fq_default_files_dir_get() {
  echo "$(mc_global_fq_scripts_dir_get)/default-files"
}

# Function: mc_global_user_name_get
# Description: Get the user name for the Minecraft server
# Parameters: None
#
mc_global_user_name_get() {
  # whoami
  echo "root"
}

# Function: mc_worlds_fq_dir_get
# Description: Get the base Minecraft worlds directory
# Parameters: None
#
mc_worlds_fq_dir_get() {
  echo "$(mc_global_fq_dir_get)/worlds"
}

# Function: mc_worlds_get
# Description: Get the worlds that have names
# Parameters: None
#
mc_worlds_get() {
  WORLDS_FQ_DIR=$(mc_worlds_fq_dir_get)
  if [ -d $WORLDS_FQ_DIR ]; then
    WORLDS=$(find $(mc_worlds_fq_dir_get) -type f -name "world-description.txt")
    if [ ! -z "$WORLDS" ]; then
      for WORLD in $WORLDS; do
        echo "$(basename $(dirname $WORLD))"
      done
    fi
  fi
}

# Function: mc_world_name_get_or_default
# Description: Get the world basename for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_name_get_or_default() {
  if [ -z "$1" ]; then
    echo $MC_DEFAULT_WORLD
  else
    echo $1
  fi
}

# Function: mc_world_fq_dir_get_or_default
# Description: Get the world directory for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_fq_dir_get_or_default() {
  MC_WORLD=$(mc_world_name_get_or_default $1)
  echo "$(mc_worlds_fq_dir_get)/$MC_WORLD"
}

# Function: mc_world_description_fq_filename_get_or_default
# Description: Get the world description fq filename for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_description_fq_filename_get_or_default() {
  echo "$(mc_world_fq_dir_get_or_default $1)/world-description.txt"
}

# Function: mc_world_description_get_or_default
# Description: Get the world description for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the world description, if not set, use the default
#
mc_world_description_get_or_default() {
  DESCRIPTION_FILE=$(mc_world_description_fq_filename_get_or_default $1)
  if [ -n "$2" ]; then
    echo $2
  elif [ -f $DESCRIPTION_FILE ]; then
    cat $DESCRIPTION_FILE
  else
    WORLD=$(mc_world_name_get_or_default $1)
    echo $WORLD
  fi
}

# Function: mc_world_description_set
# Description: Set the world description for the specified world
# Parameters:
# - $1: if one arguments: the world description
# - $1: if two arguments: the world name
# - $2: if two arguments: the world description
#
mc_world_description_set() {

  # if arg 1 and 2 are both present (use and operator)
  if [ -n "$1" ] && [ -n "$2" ]; then
    WORLD=$1
    DESCRIPTION=$2
  elif [ -n "$1" ]; then
    WORLD=$MC_DEFAULT_WORLD
    DESCRIPTION=$1
  else
    WORLD=$(mc_world_name_get_or_default $1)
    DESCRIPTION=$WORLD
  fi

  DESCRIPTION_FILE=$(mc_world_description_fq_filename_get_or_default $WORLD)
  mc_global_ensure_dir_exists $(dirname $DESCRIPTION_FILE)

  echo $DESCRIPTION > $DESCRIPTION_FILE
  cat $DESCRIPTION_FILE
}

# Function: mc_worlds_json_get
# Description: Get the worlds in "json" format
# Parameters: None
#
mc_worlds_json_get() {
  WORLDS=$(mc_worlds_get)
  if [ ! -z "$WORLDS" ]; then
    echo "["
    FIRST=true
    for WORLD in $WORLDS; do
      DESCRIPTION=$(mc_world_description_get_or_default $WORLD)
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        echo ","
      fi
      echo "  {"
      echo "    \"Name\": \"$WORLD\","
      echo "    \"Description\": \"$DESCRIPTION\"",
      echo "    \"Directory\": \"$(mc_world_fq_dir_get_or_default $WORLD)\""
      echo "  }"
    done
    echo "]"
  else
    echo "[]"
  fi
}

# Function: mc_world_java_jar_fq_filename_get_or_default
# Description: Get the world's paper-server.jar fq filename
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_java_jar_fq_filename_get_or_default() {
  echo "$(mc_world_fq_dir_get_or_default $1)/paper-server.jar"
}

# Function: mc_paper_version_latest_get
# Description: Get the latest paper version
# Parameters: None
#
mc_paper_version_latest_get() {
  PAPER_API="https://papermc.io/api/v2/projects/paper"
  PAPER_VERSION=$(curl -s $PAPER_API | jq '.versions | last')
  echo $PAPER_VERSION | tr -d '"'
}

# Function: mc_paper_version_get_or_default
# Description: Get the paper version or the latest
# Parameters:
# - $1: the version to use, if not set, use the latest
#
mc_paper_version_get_or_default() {
  if [ -z "$1" ]; then
    echo $(mc_paper_version_latest_get)
  else
    echo $1
  fi
}

# Function: mc_paper_version_build_latest_get
# Description: Get the latest paper build
# Parameters:
# - $1: the paper version to use, if not set, use the latest

mc_paper_version_build_latest_get() {
  PAPER_VERSION=$(mc_paper_version_get_or_default $1)
  PAPER_API="https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION/builds"

  # get the last build's build number
  curl -s $PAPER_API | jq '.builds | last | .build'
}

# Function: mc_paper_version_build_get_or_default
# Description: Get the paper build
# Parameters:
# - $1: the paper version to use, if not set, use the default
# - $2: the paper build to use, if not set, use the default
#
mc_paper_version_build_get_or_default() {
  if [ -z "$2" ]; then
    PAPER_VERSION=$(mc_paper_version_get_or_default $1)
    PAPER_BUILD=$(mc_paper_version_build_latest_get $PAPER_VERSION)
    echo $PAPER_BUILD
  else
    echo $2
  fi
}

# Function: mc_paper_java_jar_url_get
# Description: Get the paper jar URL
# Parameters:
# - $1: the paper version to use, if not set, use the default
# - $2: the paper build to use, if not set, use the default
#
mc_paper_java_jar_url_get() {
  PAPER_VERSION=$(mc_paper_version_get_or_default $1)
  PAPER_BUILD=$(mc_paper_version_build_get_or_default $1 $2)
  echo "https://papermc.io/api/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar"
}

# Function: mc_paper_java_jar_download
# Description: Download the PaperMC server jar file
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the paper version to use, if not set, use the default
# - $3: the paper build to use, if not set, use the default
#
mc_paper_java_jar_download() {
  WORLD=$(mc_world_name_get_or_default $1)
  JAR_FQ_FILE=$(mc_world_java_jar_fq_filename_get_or_default $WORLD)
  JAR_URL=$(mc_paper_java_jar_url_get $2 $3)

  # download the PaperMC server jar file
  echo "Downloading PaperMC"
  echo
  echo "  FROM: $JAR_URL"
  echo "    TO: $JAR_FQ_FILE"
  echo

  mc_global_ensure_dir_exists $(dirname $JAR_FQ_FILE)
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

# Function: mc_world_eula_accept
# Description: Accept the EULA for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_eula_accept() {
  WORLD=$(mc_world_name_get_or_default $1)
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)

  # change to the world directory
  mc_global_ensure_dir_exists $WORLD_FQ_DIR
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

# Function: mc_world_default_files_copy
# Description: Copy the default files to the specified world
# Parameters:
# - $1: the world name, if not set, use the default
#
mc_world_default_files_copy() {
  WORLD=$(mc_world_name_get_or_default $1)
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
  DEFAULT_FILES_FQ_DIR=$(mc_global_fq_default_files_dir_get)

  # if the world doesn't exist, exit
  if [ ! -d $WORLD_FQ_DIR ]; then
    echo -e "\e[31mWorld $WORLD does not exist.\e[0m"
    exit 1
  fi

  # for each of the files in the default files directory
  for FILE in $(ls $DEFAULT_FILES_FQ_DIR); do
    # check if the file exists in the world directory
    CHECK=$WORLD_FQ_DIR/$FILE
    if [ ! -f $CHECK ]; then
      cp $DEFAULT_FILES_FQ_DIR/$FILE $WORLD_FQ_DIR
      echo -e "\e[32mCopied default file '$FILE' to '$CHECK' copied.\e[0m"
    fi
  done
}

# Function: mc_world_create
# Description: Create a new world
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the world description, if not set, use the default
# - $3: the paper version to use, if not set, use the default
# - $4: the paper build to use, if not set, use the default
#
mc_world_create() {
  WORLD=$(mc_world_name_get_or_default $1)
  echo "Creating world $WORLD ..."
  WORLD_DESCRIPTION=$(mc_world_description_get_or_default $WORLD "$2")
  echo "  Description: $WORLD_DESCRIPTION"
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
  echo "  Directory: $WORLD_FQ_DIR"
  PAPER_VERSION=$(mc_paper_version_get_or_default $3)
  echo "  Paper Version: $PAPER_VERSION"
  PAPER_BUILD=$(mc_paper_version_build_get_or_default $PAPER_VERSION $4)
  echo "  Paper Build: $PAPER_BUILD"
  echo

  # if the world already exists, exit
  if [ -d $WORLD_FQ_DIR ]; then
    echo -e "\e[31mWorld $WORLD already exists.\e[0m"
    exit 1
  fi

  # create the world directory
  mc_global_ensure_dir_exists $WORLD_FQ_DIR

  # set the world description
  mc_world_description_set $WORLD "$WORLD_DESCRIPTION"

  # download the PaperMC server jar file
  mc_paper_java_jar_download $WORLD $PAPER_VERSION $PAPER_BUILD

  # accept the EULA
  mc_world_eula_accept $WORLD

  echo -e "\e[32m$WORLD created successfully.\e[0m"
}

# Function: mc_world_update_paper_version
# Description: Update the PaperMC version for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the paper version to use, if not set, use the default
# - $3: the paper build to use, if not set, use the default
#
mc_world_update_paper_version() {
  WORLD=$(mc_world_name_get_or_default $1)
  echo "Updating world $WORLD ..."
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
  echo "  Directory: $WORLD_FQ_DIR"
  PAPER_VERSION=$(mc_paper_version_get_or_default $2)
  echo "  Paper Version: $PAPER_VERSION"
  PAPER_BUILD=$(mc_paper_version_build_get_or_default $PAPER_VERSION $3)
  echo "  Paper Build: $PAPER_BUILD"
  echo

  # if world doesn't exist, exit
  if [ ! -d $WORLD_FQ_DIR ]; then
    echo -e "\e[31mWorld $WORLD does not exist.\e[0m"
    exit 1
  fi

  # download the PaperMC server jar file
  mc_paper_java_jar_download $WORLD $PAPER_VERSION $PAPER_BUILD

  echo -e "\e[32m$WORLD updated to PaperMC $PAPER_VERSION build $PAPER_BUILD.\e[0m"
}

# Function: mc_world_update_description
# Description: Update the description for the specified world
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the world description
#
mc_world_update_description() {
  WORLD=$(mc_world_name_get_or_default $1)
  echo "Updating world $WORLD ..."
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
  echo "  Directory: $WORLD_FQ_DIR"
  WORLD_DESCRIPTION=$(mc_world_description_get_or_default $WORLD "$2")
  echo "  Description: $WORLD_DESCRIPTION"
  echo

  # if world doesn't exist, exit
  if [ ! -d $WORLD_FQ_DIR ]; then
    echo -e "\e[31mWorld $WORLD does not exist.\e[0m"
    exit 1
  fi

  # set the world description
  mc_world_description_set $WORLD "$WORLD_DESCRIPTION"

  echo -e "\e[32m$WORLD description updated to $WORLD_DESCRIPTION.\e[0m"
}

# Function: mc_service_slot_get_or_default
# Description: Get the service "slot" or the default
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_get_or_default() {
  if [ -z "$1" ]; then
    echo 1
  else
    echo $1
  fi
}

# Function: mc_service_slot_name_get
# Description: Get the service file name for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_name_get() {
  echo "minecraft-slot-$(mc_service_slot_get_or_default $1).service"
}

# Function: mc_service_slot_fq_filename_get
# Description: Get the service file fq filename for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_fq_filename_get() {
  echo "/etc/systemd/system/$(mc_service_slot_name_get $1)"
}

# Function: mc_service_slot_start
# Description: Start the service for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_start() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  SERVICE_NAME=$(mc_service_slot_name_get $SERVER_SLOT)

  echo "Starting service $SERVICE_NAME ..."
  sudo systemctl start $SERVICE_NAME
  echo "Starting service $SERVICE_NAME ... Done!"
  echo
}

# Function: mc_service_slot_stop
# Description: Stop the service for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_stop() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  SERVICE_NAME=$(mc_service_slot_name_get $SERVER_SLOT)

  echo "Stopping service $SERVICE_NAME ..."
  sudo systemctl stop $SERVICE_NAME
  echo "Stopping service $SERVICE_NAME ... Done!"
  echo
}

# Function: mc_service_slot_reload_daemon
# Description: Reload the systemd daemon
# Parameters: None
#
mc_service_slot_reload_daemon() {
  echo "Reloading systemd ..."
  sudo systemctl daemon-reload
  echo "Reloading systemd ... Done!"
  echo
}

# Function: mc_service_slot_enable
# Description: Enable the service for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_enable() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  SERVICE_NAME=$(mc_service_slot_name_get $SERVER_SLOT)

  echo "Enabling service ..."
  sudo systemctl enable $SERVICE_NAME
  echo "Enabling service ... Done!"
  echo
}

# Function: mc_service_slot_world_name_fq_filename_get_or_default
# Description: Get the slot world name fq filename for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_world_name_fq_filename_get_or_default() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  echo "$(mc_global_fq_dir_get)/slot-$SERVER_SLOT-world-name.txt"
}

# Function: mc_service_slot_world_name_get_or_default
# Description: Get the slot world name for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_world_name_get_or_default() {
  SLOT_WORLD_NAME_FILE=$(mc_service_slot_world_name_fq_filename_get_or_default $1)
  if [ -f $SLOT_WORLD_NAME_FILE ]; then
    cat $SLOT_WORLD_NAME_FILE
  else
    echo $(mc_world_name_get_or_default)
  fi
}

# Function: mc_service_slot_world_name_set
# Description: Set the slot world name for the specified slot
# Parameters:
# - $1: the slot number, if not set, use the default
# - $2: the world name
#
mc_service_slot_world_name_set() {
  SLOT_WORLD_NAME_FILE=$(mc_service_slot_world_name_fq_filename_get_or_default $1)
  mc_global_ensure_dir_exists $(dirname $SLOT_WORLD_NAME_FILE)
  echo $2 > $SLOT_WORLD_NAME_FILE
  cat $SLOT_WORLD_NAME_FILE
}

# Function: mc_world_service_slot_file_content_get
# Description: Get the service file content for the specified world and slot
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_world_service_slot_file_content_get() {
  WORLD=$(mc_world_name_get_or_default $1)
  SERVER_SLOT=$(mc_service_slot_get_or_default $2)
  SERVER_SLOT_NAME=$(mc_service_slot_name_get $SERVER_SLOT)

  JAVA_DIR=$(dirname $(which java))
  JAR_FQ_FILE=$(mc_world_java_jar_fq_filename_get_or_default $WORLD)
  WORLD_FQ_DIR=$(mc_world_fq_dir_get_or_default $WORLD)
  MC_USER=$(mc_global_user_name_get)

  _=$(mc_world_description_set $WORLD)

  # output the service file
  echo "# minecraft.service"
  echo ""
  echo "[Unit]"
  echo "Description=$SERVER_SLOT_NAME"
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

# Function: mc_world_service_slot_file_create
# Description: Create the service file for the specified world and slot
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_world_service_slot_file_create() {
  TEMP_FILE_NAME=temp-file.service

  # create a temp version of the service file
  SERVICE_FILE_CONTENT=$(mc_world_service_slot_file_content_get $1 $2)
  echo "$SERVICE_FILE_CONTENT" > $TEMP_FILE_NAME

  # copy the temp file to the service file
  SERVER_SLOT=$(mc_service_slot_get_or_default $2)
  SERVICE_FQ_FILE_NAME=$(mc_service_slot_fq_filename_get $SERVER_SLOT)
  sudo cp $TEMP_FILE_NAME $SERVICE_FQ_FILE_NAME
  rm $TEMP_FILE_NAME

  echo $SERVICE_FQ_FILE_NAME
}

# Function: mc_world_service_slot_port_get
# Description: Get the port for the specified world and slot
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_world_service_slot_port_get() {
  WORLD=$(mc_world_name_get_or_default $1)
  SERVER_SLOT=$(mc_service_slot_get_or_default $2)

  # use port 25565 for slot 1
  # use port 25566 for slot 2
  # ...
  echo $((25564 + $SERVER_SLOT))
}

# Function: mc_world_server_properties_update
# Description: Update the server properties file for the specified world and slot
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_world_server_properties_update() {
  WORLD=$(mc_world_name_get_or_default $1)
  SERVER_SLOT=$(mc_service_slot_get_or_default $2)
  SERVER_SLOT_PORT=$(mc_world_service_slot_port_get $WORLD $SERVER_SLOT)
  SERVER_PROPERTIES_FQ_FILE=$(mc_world_fq_dir_get_or_default $WORLD)/server.properties

  # if the server properties file doesn't exist, create it
  if [ ! -f $SERVER_PROPERTIES_FQ_FILE ]; then
    mc_world_default_files_copy $WORLD
  fi

  # update the server properties file
  sed -i "s/server-port=.*/server-port=$SERVER_SLOT_PORT/g" $SERVER_PROPERTIES_FQ_FILE
}

# Function: mc_world_start_in_slot
# Description: Start the specified world in the specified slot
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_world_start_in_slot() {
  WORLD=$(mc_world_name_get_or_default $1)
  SERVER_SLOT=$(mc_service_slot_get_or_default $2)
  SERVICE_FQ_FILE_NAME=$(mc_service_slot_fq_filename_get $SERVER_SLOT)
  JAR_FQ_FILE=$(mc_world_java_jar_fq_filename_get_or_default $WORLD)

  # if the world doesn't exist, exit
  if [ ! -d $(mc_world_fq_dir_get_or_default $WORLD) ]; then
    echo -e "\e[31mWorld $WORLD does not exist.\e[0m"
    exit 1
  fi

  # if the java jar file doesn't exist, exit
  if [ ! -f $JAR_FQ_FILE ]; then
    echo -e "\e[31mWorld $WORLD does not have a paper-server.jar file.\e[0m"
    exit 1
  fi

  # stop the previous service if it exists
  if [ -f $SERVICE_FQ_FILE_NAME ]; then
    mc_service_slot_stop $SERVER_SLOT
  fi

  # update the server properties file
  mc_world_server_properties_update $WORLD $SERVER_SLOT

  # update the slot world name
  mc_service_slot_world_name_set $SERVER_SLOT $WORLD

  # create the new service file
  echo "Updating service for world: $WORLD, slot: $SERVER_SLOT ..."
  _=$(mc_world_service_slot_file_create $WORLD $SERVER_SLOT)
  echo "Updating service for world: $WORLD, slot: $SERVER_SLOT ... Done!"
  echo

  # reload the systemd daemon
  mc_service_slot_reload_daemon

  # enable the service
  mc_service_slot_enable $SERVER_SLOT
  
  # start the service
  mc_service_slot_start $SERVER_SLOT
}

# Function: mc_check_service_slot
# Description: Check the status of the specified service slot
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_check_service_slot() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  SERVICE_NAME=$(mc_service_slot_name_get $SERVER_SLOT)

  echo "Checking service $SERVICE_NAME ..."
  STATUS=$(systemctl status $SERVICE_NAME)
  echo "$STATUS"
  echo
}

# Function: mc_service_slot_wait_for_timings_reset
# Description: Wait for the "Timings Reset" message
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_service_slot_wait_for_timings_reset() {
  SERVER_SLOT=$(mc_service_slot_get_or_default $1)
  SERVICE_NAME=$(mc_service_slot_name_get $SERVER_SLOT)
  SERVICE_FQ_FILE_NAME=$(mc_service_slot_fq_filename_get $SERVER_SLOT)

  # if the service file doesn't exist, exit
  if [ ! -f $SERVICE_FQ_FILE_NAME ]; then
    echo -e "\e[31mService $SERVICE_NAME does not exist.\e[0m"
    exit 1
  fi

  # check the status before we go into looping...
  STATUS=$(systemctl status $SERVICE_NAME)
  if [[ $STATUS == *"Timings Reset"* ]]; then
    echo -e "\e[32mTimings Reset\e[0m"
    return
  fi

  echo "Waiting for Timings Reset ..."
  echo
  echo "  Press Ctrl+C to stop waiting."
  echo

  # wait for the "Timings Reset" message
  while true; do
    STATUS=$(systemctl status $SERVICE_NAME)
    if [[ $STATUS == *"Timings Reset"* ]]; then
      echo -e "\e[32mTimings Reset\e[0m"
      break
    fi
    sleep 1
  done
}

# Function: mc_test_global_get_functions
# Description: Test the global functions that accept no parameters
# Parameters: None
#
mc_test_global_get_functions() {
  echo mc_global_dependencies_check=$(mc_global_dependencies_check)
  echo mc_global_user_name_get=$(mc_global_user_name_get)
  echo mc_global_fq_dir_get=$(mc_global_fq_dir_get)
  echo mc_global_fq_scripts_dir_get=$(mc_global_fq_scripts_dir_get)
  echo mc_global_fq_default_files_dir_get=$(mc_global_fq_default_files_dir_get)
  echo
  echo mc_worlds_fq_dir_get=$(mc_worlds_fq_dir_get)
  echo mc_worlds_get=$(mc_worlds_get)
  echo mc_worlds_json_get=$(mc_worlds_json_get)
}

# Function: mc_test_world_get_functions
# Description: Test the non-version functions
# Parameters:
# - $1: the world name, if not set, use the default
# - $2: the slot number, if not set, use the default
#
mc_test_world_get_functions() {
  echo mc_world_fq_dir_get_or_default=$(mc_world_fq_dir_get_or_default $1)
  echo mc_world_description_fq_filename_get_or_default=$(mc_world_description_fq_filename_get_or_default $1)
  echo mc_world_description_get_or_default=$(mc_world_description_get_or_default $1)
  echo mc_world_java_jar_fq_filename_get_or_default=$(mc_world_java_jar_fq_filename_get_or_default $1)
  echo mc_world_service_slot_file_content_get=$(mc_world_service_slot_file_content_get $1 $2)
  echo mc_world_service_slot_port_get=$(mc_world_service_slot_port_get $1 $2)
}

# Function: mc_test_service_slot_get_functions
# Description: Test the service slot functions
# Parameters:
# - $1: the slot number, if not set, use the default
#
mc_test_service_slot_get_functions() {
  echo mc_service_slot_get_or_default=$(mc_service_slot_get_or_default $1)
  echo mc_service_slot_name_get=$(mc_service_slot_name_get $1)
  echo mc_service_slot_fq_filename_get=$(mc_service_slot_fq_filename_get $1)
  echo mc_service_slot_world_name_fq_filename_get_or_default=$(mc_service_slot_world_name_fq_filename_get_or_default $1)
  echo mc_service_slot_world_name_get_or_default=$(mc_service_slot_world_name_get_or_default $1)
}

# Function: mc_test_paper_get_version_and_build_functions
# Description: Test the version functions
# Parameters:
# - $1: the paper version to use, if not set, use the default
# - $2: the paper build to use, if not set, use the default
#
mc_test_paper_get_version_and_build_functions() {
  echo mc_paper_version_latest_get=$(mc_paper_version_latest_get $1 $2)
  echo mc_paper_version_get_or_default=$(mc_paper_version_get_or_default $1 $2)
  echo mc_paper_version_build_latest_get=$(mc_paper_version_build_latest_get $1 $2)
  echo mc_paper_version_build_get_or_default=$(mc_paper_version_build_get_or_default $1 $2)
  echo mc_paper_java_jar_url_get=$(mc_paper_java_jar_url_get $1 $2)
}

mc_test_overall() {

  mc_test_global_get_functions

  DO_PAPER_VERSION_TESTS=false
  DO_WORLD_TESTS=false
  DO_SERVICE_SLOT_TESTS=false

  if [ "$1" == "1" ]; then
    DO_SERVICE_SLOT_TESTS=true
  elif [ "$1" == "2" ]; then
    DO_SERVICE_SLOT_TESTS=true
  elif [ -z "$1" ]; then
    DO_PAPER_VERSION_TESTS=true
    DO_WORLD_TESTS=true
  elif [[ $1 == 1.* ]]; then
    DO_PAPER_VERSION_TESTS=true
  else
    DO_WORLD_TESTS=true
  fi

  if [ "$DO_SERVICE_SLOT_TESTS" = true ]; then
    mc_test_service_slot_get_functions $1
  fi

  if [ "$DO_WORLD_TESTS" = true ]; then
    mc_test_world_get_functions $1 $2
  fi

  if [ "$DO_PAPER_VERSION_TESTS" = true ]; then
    mc_test_paper_get_version_and_build_functions $1 $2
  fi
}
