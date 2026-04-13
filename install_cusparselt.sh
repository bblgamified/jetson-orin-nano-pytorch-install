#!/bin/bash
set -euo pipefail

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

CUDA_VERSION="${CUDA_VERSION:-12.6}"

case "$CUDA_VERSION" in
  12.*)
    CUSPARSELT_NAME="libcusparse_lt-linux-aarch64-0.8.1.1_cuda12-archive"
    BASE_URL="https://developer.download.nvidia.com/compute/cusparselt/redist/libcusparse_lt/linux-aarch64"
    ;;
  13.*)
    CUSPARSELT_NAME="libcusparse_lt-linux-aarch64-0.8.1.1_cuda13-archive"
    BASE_URL="https://developer.download.nvidia.com/compute/cusparselt/redist/libcusparse_lt/linux-aarch64"
    ;;
  *)
    echo "Unsupported CUDA_VERSION: $CUDA_VERSION"
    exit 1
    ;;
esac

ARCHIVE="${CUSPARSELT_NAME}.tar.xz"

curl --fail --retry 3 -LO "${BASE_URL}/${ARCHIVE}"
tar xf "${ARCHIVE}"

sudo cp -a "${CUSPARSELT_NAME}/include/." /usr/local/cuda/include/
sudo cp -a "${CUSPARSELT_NAME}/lib/." /usr/local/cuda/lib64/
sudo ldconfig

echo "Installed ${CUSPARSELT_NAME}"
