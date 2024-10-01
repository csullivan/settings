# Start from the PyTorch image
FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-devel


RUN apt-get update && \
    apt-get install -y curl wget libglib2.0-0 && \
    apt-get clean

# Install Node.js via Nodesource setup script
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Install nsys as this base image only contains nsight compute
ARG NSYS_URL=https://developer.nvidia.com/downloads/assets/tools/secure/nsight-systems/2024_4/
ARG NSYS_PKG=NsightSystems-linux-cli-public-2024.4.1.61-3431596.deb
RUN wget ${NSYS_URL}${NSYS_PKG} && dpkg -i $NSYS_PKG && rm $NSYS_PKG

# Update and install necessary tools
RUN apt update && apt install -y wget curl software-properties-common

# Add LLVM's official repository
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" | tee /etc/apt/sources.list.d/llvm.list

RUN add-apt-repository ppa:kelleyk/emacs
RUN apt update
RUN apt install -y emacs28
RUN apt-get install -y sudo
RUN apt install -y tmux
RUN apt install -y docker
RUN apt install -y nvtop
RUN apt install -y git-lfs
RUN git lfs install


# Clean up the apt cache to reduce the image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/conda/lib/python3.11/site-packages/nvidia/cudnn/lib
CMD ["bash"]

