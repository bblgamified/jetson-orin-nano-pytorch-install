# Install PyTorch with CUDA on Jetson Orin Nano (JetPack 6.2.1 / CUDA 12.6)

This guide installs a working GPU-enabled PyTorch setup on:

- Jetson Orin Nano
- JetPack `6.2.1+b38`
- CUDA `12.6`
- Python `3.10`

This setup was verified with:

- `torch==2.11.0`
- `torchvision==0.26.0`
- `torchaudio==2.10.0`

## 1. Confirm system versions

```bash
python3 --version
uname -m
nvcc --version

Expected:

Python 3.10.x
Architecture aarch64
CUDA 12.6
2. Activate your Python environment

If you are using a virtual environment, activate it first.

Example:

cd ~/dev/retro-diffusion/ai
source comfy/bin/activate

Confirm the interpreter:

python3 -c "import sys; print(sys.executable)"
3. Remove old PyTorch packages
pip3 uninstall -y torch torchvision torchaudio
pip3 cache purge
4. Install a compatible NumPy version
pip3 install "numpy<2"
5. Install PyTorch from the Jetson AI Lab CUDA 12.6 index
pip3 install --no-cache-dir \
  --index-url https://pypi.jetson-ai-lab.io/jp6/cu126 \
  torch==2.11.0 \
  torchvision==0.26.0

Optional audio package:

pip3 install --no-cache-dir \
  --index-url https://pypi.jetson-ai-lab.io/jp6/cu126 \
  torchaudio==2.10.0
6. Install CuDSS runtime dependency

The current torch==2.11.0 CUDA 12.6 build requires libcudss.so.0.

Create a temporary directory and download CuDSS:

mkdir -p ~/tmp_cudss
cd ~/tmp_cudss

CUSPARSE_SOLVER_NAME="libcudss-linux-sbsa-0.6.0.5_cuda12-archive"
curl -L -O "https://developer.download.nvidia.com/compute/cudss/redist/libcudss/linux-sbsa/${CUSPARSE_SOLVER_NAME}.tar.xz"
tar xf "${CUSPARSE_SOLVER_NAME}.tar.xz"

Copy the headers and libraries into CUDA 12.6:

sudo cp -a "${CUSPARSE_SOLVER_NAME}"/include/* /usr/local/cuda-12.6/include/
sudo cp -a "${CUSPARSE_SOLVER_NAME}"/lib/* /usr/local/cuda-12.6/lib64/
sudo ldconfig

Optional cleanup:

cd ~
rm -rf ~/tmp_cudss
7. Verify CuDSS is installed
ls -l /usr/local/cuda-12.6/lib64/libcudss.so*
sudo ldconfig -p | grep cudss

You should see entries for:

libcudss.so
libcudss.so.0
libcudss.so.0.6.0
8. Verify PyTorch is using the GPU
python3 - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("device:", torch.cuda.get_device_name(0))
PY

Expected output:

torch: 2.11.0
cuda: True
device: Orin
9. Full verification
python3 - <<'PY'
import torch, torchvision

print("torch:", torch.__version__)
print("torchvision:", torchvision.__version__)
print("cuda:", torch.cuda.is_available())
print("device:", torch.cuda.get_device_name(0))

x = torch.rand(4, 4, device="cuda")
print("tensor device:", x.device)
PY

Expected output:

torch: 2.11.0
torchvision: 0.26.0
cuda: True
device: Orin
tensor device: cuda:0
Notes
This uses the current Jetson AI Lab package index for jp6/cu126
The PyTorch install may succeed before runtime works
If import torch fails with:
ImportError: libcudss.so.0: cannot open shared object file

that means CuDSS is missing and Step 6 is required

Working package versions
Jetson Orin Nano
JetPack 6.2.1+b38
CUDA 12.6
Python 3.10
torch 2.11.0
torchvision 0.26.0
torchaudio 2.10.0
CuDSS runtime installed manually
