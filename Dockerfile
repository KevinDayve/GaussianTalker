#nvidia toolkit image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

#This is to avoid prompts while apt-installing.
ENV DEBIAN_FRONTEND=noninteractive
#For Ampere GPUs - change as required.
ENV TORCH_CUDA_ARCH_LIST="8.6"
# this ensures build sanctity - otherwise the image may be built with a different CUDA version than the one used to build the PyTorch wheel
ENV CUDAARCHS="86"

#Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3-dev \
    ffmpeg \
    git \
    libsm6 \
    libxext6 \
    libglm-dev \
    portaudio19-dev \
    libasound-dev \
    build-essential \
    ninja-build \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*

#Set python and pip aliases
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

#Set working directory
WORKDIR /app

#Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir torch==1.13.1+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

#Copy submodules & install
COPY submodules submodules
RUN pip install -e submodules/custom-bg-depth-diff-gaussian-rasterization && \
    pip install -e submodules/simple-knn && \
    pip install "git+https://github.com/facebookresearch/pytorch3d.git"

#TensorFlow & protobuf
RUN pip install --no-cache-dir tensorflow-gpu==2.8.0 "protobuf<=3.20.1"

#Copy the rest of the repo
COPY . .

#Default shell
CMD ["/bin/bash"]