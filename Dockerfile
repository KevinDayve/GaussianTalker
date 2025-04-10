FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

#Avoid Prompts during package installations.
ENV DEBIAN_FRONTEND=noninteractive

#Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-tk \
    ffmpeg \
    git \
    portaudio19-dev \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

#Set python and pip aliases
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

#install python dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir torch==1.13.1+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

COPY submodules submodules
RUN pip install -e submodules/custom-bg-depth-diff-gaussian-rasterization && \
    pip install -e submodules/simple-knn
#Install TensorFlow and protobuf
RUN pip install --no-cache-dir tensorflow-gpu==2.8.0 "protobuf<=3.20.1"

#Copy the rest of the repo
COPY . .

#deafult shell
CMD ["/bin/bash"]
