# ComfyUI on Jetson Orin Nano (GPU Enabled)
This guide installs **ComfyUI using the Jetson GPU** on:

- Jetson Orin Nano 8GB
- JetPack 6.2.1
- CUDA 12.6
- Python 3.10
- GPU PyTorch (Jetson AI Lab)

This uses the PyTorch install from:
https://github.com/bblgamified/jetson-orin-nano-pytorch-install

---

# 1. System Prep

```bash
sudo apt update
sudo apt install -y git python3-venv python3-pip python-is-python3
```

---

# 2. Create Working Directory

```bash
mkdir -p ~/dev/retro-diffusion/ai
cd ~/dev/retro-diffusion/ai
```

---

# 3. Create Python Virtual Environment

```bash
python3 -m venv comfy
source ~/dev/retro-diffusion/ai/comfy/bin/activate
python -m pip install --upgrade pip setuptools wheel
```

---

# 4. Install Jetson GPU PyTorch

Clone repo:

```bash
cd ~/dev
git clone https://github.com/bblgamified/jetson-orin-nano-pytorch-install.git
cd jetson-orin-nano-pytorch-install
```

Activate venv:

```bash
source ~/dev/retro-diffusion/ai/comfy/bin/activate
```

Remove old torch:

```bash
pip uninstall -y torch torchvision torchaudio
pip cache purge
pip install "numpy<2"
```

Install Jetson PyTorch:

```bash
pip install --no-cache-dir --index-url https://pypi.jetson-ai-lab.io/jp6/cu126 torch==2.11.0 torchvision==0.26.0
```

Optional:

```bash
pip install --no-cache-dir --index-url https://pypi.jetson-ai-lab.io/jp6/cu126 torchaudio==2.10.0
```

Install CuDSS:

```bash
mkdir -p ~/tmp_cudss
cd ~/tmp_cudss

CUSPARSE_SOLVER_NAME="libcudss-linux-sbsa-0.6.0.5_cuda12-archive"
curl -L -O "https://developer.download.nvidia.com/compute/cudss/redist/libcudss/linux-sbsa/${CUSPARSE_SOLVER_NAME}.tar.xz"
tar xf "${CUSPARSE_SOLVER_NAME}.tar.xz"

sudo cp -a "${CUSPARSE_SOLVER_NAME}"/include/* /usr/local/cuda-12.6/include/
sudo cp -a "${CUSPARSE_SOLVER_NAME}"/lib/* /usr/local/cuda-12.6/lib64/
sudo ldconfig
```

Verify GPU:

```bash
python - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("device:", torch.cuda.get_device_name(0))
PY
```

---

# 5. Install ComfyUI

```bash
cd ~/dev/retro-diffusion/ai
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
```

---

# 6. Install Requirements

```bash
source ~/dev/retro-diffusion/ai/comfy/bin/activate
pip install -r requirements.txt
```

---

# 7. Verify Torch Still Using GPU

```bash
python - <<'PY'
import torch
print("CUDA:", torch.cuda.is_available())
print("Device:", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "none")
PY
```

If CUDA is false reinstall torch.

---

# 8. Run ComfyUI (Jetson Recommended)

```bash
cd ~/dev/retro-diffusion/ai/ComfyUI
source ~/dev/retro-diffusion/ai/comfy/bin/activate
python main.py --listen 0.0.0.0 --port 8188 --lowvram --force-fp16
```

Open:

```
http://JETSON_IP:8188
```

---

# 9. Alternative Launch Options

Safer VAE:

```bash
python main.py --listen 0.0.0.0 --port 8188 --lowvram --force-fp16 --fp32-vae
```

If CUDA issues:

```bash
python main.py --listen 0.0.0.0 --port 8188 --lowvram --force-fp16 --disable-cuda-malloc
```

---

# 10. Model Directory

Place models here:

```
~/dev/retro-diffusion/ai/ComfyUI/models/checkpoints/
```

---

# 11. Run As Service (Optional)

Create service:

```bash
sudo nano /etc/systemd/system/comfyui.service
```

Paste:

```ini
[Unit]
Description=ComfyUI
After=network.target

[Service]
User=robi
WorkingDirectory=/home/robi/dev/retro-diffusion/ai/ComfyUI
Environment="PATH=/home/robi/dev/retro-diffusion/ai/comfy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/home/robi/dev/retro-diffusion/ai/comfy/bin/python /home/robi/dev/retro-diffusion/ai/ComfyUI/main.py --listen 0.0.0.0 --port 8188 --lowvram --force-fp16
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now comfyui
```

Logs:

```bash
journalctl -u comfyui -f
```

---

# 12. Update ComfyUI

```bash
cd ~/dev/retro-diffusion/ai/ComfyUI
source ~/dev/retro-diffusion/ai/comfy/bin/activate
git pull
pip install -r requirements.txt
```

---

# Done

ComfyUI is now running with Jetson GPU acceleration.
