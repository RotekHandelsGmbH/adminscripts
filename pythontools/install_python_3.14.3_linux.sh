#!/bin/bash

# Define the full Python version to install
PYTHON_VERSION="3.14.3"
PYTHON_VERSION_SHORT=$(echo "$PYTHON_VERSION" | cut -d. -f1,2)

# Default: prompt is shown
SHOW_PROMPT=true

# Parse script arguments
for arg in "$@"; do
  case "$arg" in
    --no-prompt)
      SHOW_PROMPT=false
      ;;
    -h|--help)
      echo "Usage: $0 [--no-prompt]"
      echo ""
      echo "Options:"
      echo "  --no-prompt     Skip the 'Press any key to continue' pause."
      echo "  -h, --help      Show this help message and exit."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Use --help to see available options."
      exit 1
      ;;
  esac
done

# Pause for user confirmation unless --no-prompt is set
if $SHOW_PROMPT; then
  echo "will install Python ${PYTHON_VERSION} to /opt/python-lastest, press any key to continue..."
  read -n 1 -s
fi

# Check if the script is being run as root. If not, exit with a message.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Exiting."
  exit 1
fi

# (…der Rest deines Scripts bleibt unverändert …)


# Update the system's package list
apt-get update

# Install required development tools and libraries for building Python from source
apt-get install -y build-essential libssl-dev zlib1g-dev \
  libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
  libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev \
  wget curl llvm libffi-dev

rm -rf /opt/python-${PYTHON_VERSION}
rm -rf /opt/python-latest
rm -rf /opt/python-latest-clean

# Create and move into the /usr/src directory for downloading source code
mkdir -p /usr/src
cd /usr/src

# Download the specified version of Python source tarball
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

# Create a directory to extract the tarball into, stripping the top-level folder from the archive
mkdir -p /usr/src/Python-${PYTHON_VERSION}
tar xzf Python-${PYTHON_VERSION}.tgz --strip-components=1 -C /usr/src/Python-${PYTHON_VERSION}

# Change into the extracted Python source directory
cd /usr/src/Python-${PYTHON_VERSION}

# Configure the Python build:
# --enable-optimizations enables PGO for better performance
# --prefix sets the custom installation directory
sudo ./configure --enable-optimizations --prefix=/opt/python-${PYTHON_VERSION}-clean

# Build Python using all available CPU cores
sudo make -j$(nproc)

# Install Python to the target directory without overwriting the system's default python3 binary
sudo make altinstall

# cleanup
cd /usr/src
rm -f /usr/src/Python-${PYTHON_VERSION}.tgz
rm -rf /usr/src/Python-${PYTHON_VERSION}

ln -s /opt/python-${PYTHON_VERSION}-clean/bin/python${PYTHON_VERSION_SHORT} /opt/python-${PYTHON_VERSION}-clean/bin/python
/opt/python-${PYTHON_VERSION}-clean/bin/python -m pip install virtualenv
/opt/python-${PYTHON_VERSION}-clean/bin/python -m virtualenv --copies /opt/python-latest-clean


if $SHOW_PROMPT; then
  echo "finished."
  echo "----------------------------------------------------------------"
  echo "create your (linked to /opt/python-latest-clean) environment with: "
  echo "sudo /opt/python-latest-clean/bin/python -m venv /opt/<env_name>"
  echo "----------------------------------------------------------------"
  echo "create your indipendent portable environment with: "
  echo "for root : "
  echo "sudo /opt/python-latest-clean/bin/python -m virtualenv --copies /opt/<env_name>"
  echo "for specific user : "
  echo "/opt/python-latest-clean/bin/python -m virtualenv --copies /home/<username>/<env_name>"
  echo "----------------------------------------------------------------"
  echo "press any key to continue..."
  read -n 1 -s
fi

