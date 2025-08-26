# Build and Install the Latest CPython with GCC

This script automates the process of downloading, compiling, and installing the latest stable version of CPython (the reference Python implementation) from source using the GCC compiler toolchain.

It is designed for Debian-based systems (like Ubuntu) and ensures that all necessary dependencies are met. The script also provides an option to compile with high-performance flags for a faster, optimized Python interpreter.

## Key Features

-   **Fetches Latest Version**: Automatically finds and downloads the latest stable CPython tag from the official GitHub repository.
-   **Dependency Management**: Checks for and installs required build tools and libraries (e.g., `build-essential`, `libssl-dev`).
-   **Optimized Build (Optional)**: Prompts the user to apply aggressive optimization flags (`-O3`, `-march=native`, `-flto`) for a high-performance build tailored to the host machine's CPU.
-   **Idempotent Installation**: Installs Python into a versioned directory (e.g., `/opt/python-3.12.4`) and creates a stable symlink (`/opt/python-latest`) pointing to it.
-   **Safe & Clean**: Uses `make altinstall` to avoid overwriting the system's default `python3` binary and includes robust cleanup to remove temporary build files.
-   **Pre-flight Checks**: Verifies it is run with root privileges before making any system changes.

## Requirements

-   A Debian-based Linux distribution (e.g., Ubuntu, Debian).
-   Root privileges (the script must be run with `sudo`).
-   An active internet connection to download dependencies and the CPython source code.

## Usage

1.  **Make the script executable:**
    ```bash
    chmod +x install_latest_python_gcc.sh
    ```

2.  **Run the script with root privileges:**
    ```bash
    sudo ./install_latest_python_gcc.sh
    ```

The script will first install any missing dependencies. It will then prompt you to decide whether to apply performance optimization flags.

### Performance Optimizations

You will be asked the following question:

```
❓ Do you want to apply these flags for your build? You will be able to execute python only at this machines CPU (march=native) [y/N]:
```

-   **Answering `y` (Yes)**:
    -   Sets `CFLAGS`, `CXXFLAGS`, and `LDFLAGS` to aggressively optimize the build.
    -   The resulting Python interpreter will be highly optimized for your specific CPU architecture (`-march=native`).
    -   **Caveat**: The compiled binaries may not be portable; they might not run on machines with a different or older CPU.

-   **Answering `n` (No)**:
    -   The script proceeds with Python's default, more conservative optimization settings (`--enable-optimizations`).
    -   The resulting build will be more portable and compatible with a wider range of CPUs.

## Installation Details

The script performs the installation in two main locations:

1.  **Versioned Directory**: The primary installation occurs in a directory named after the specific Python version, such as `/opt/python-3.12.4`. This keeps each version isolated.

2.  **Latest Symlink**: A symbolic link is created at `/opt/python-latest`, which always points to the most recently installed versioned directory. This provides a consistent path to the latest Python interpreter.

### Post-Installation

After a successful installation, the script will remind you of the best practice for creating virtual environments:

```
⚠️  Always create virtual environments from the versioned interpreter:
    /opt/python-3.12.4/bin/python3 -m venv <your_env_name>
```

Using the version-specific path ensures you are creating an environment with the exact Python version you intended.

## Configuration

The following variables can be modified at the top of the script to change the default paths:

-   `PYTHON_LATEST_DIR`: The path for the "latest" symlink. (Default: `/opt/python-latest`)
-   `TMP_DIR`: The directory for downloading and extracting the source code. (Default: `/tmp`)
-   `PYTHON_SYMLINK_NAME`: The name of the main Python executable symlink inside the installation directory. (Default: `python3`)
-   `PIP_SYMLINK_NAME`: The name of the pip executable symlink. (Default: `pip3`)