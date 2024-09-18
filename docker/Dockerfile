FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

ARG USER_ID
ARG GROUP_ID

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Update and install necessary tools
RUN apt update && apt install -y wget curl software-properties-common

# Add LLVM's official repository
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" | tee /etc/apt/sources.list.d/llvm.list

# Add NVIDIA's cuda repository for nccl upgrade
RUN echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" | tee /etc/apt/sources.list.d/nvidia-cuda.list && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub

RUN add-apt-repository ppa:kelleyk/emacs
RUN apt update
RUN apt install -y --allow-change-held-packages libnccl-dev libnccl2
RUN apt install -y git python3-pip python3.11 cmake
RUN apt install -y emacs28
RUN apt-get install -y sudo
RUN apt install -y tmux
RUN apt install -y docker
RUN apt install -y nvtop
RUN apt install -y git-lfs
RUN git lfs install



RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

RUN echo "csullivan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/csullivan
# RUN rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install torch torchvision torchaudio
RUN python3 -m pip install transformers

# axolotl
RUN pip3 install packaging
RUN pip3 install -e '.[flash-attn,deepspeed]'



RUN groupadd -g ${GROUP_ID} csullivan && \
    useradd -l -u ${USER_ID} -g csullivan csullivan && \
    install -d -m 0755 -o csullivan -g csullivan /home/csullivan


USER csullivan
WORKDIR /home/csullivan

