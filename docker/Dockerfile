# Start from the PyTorch image
FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-devel

# Install curl
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

# Install Node.js via Nodesource setup script
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs



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
# RUN apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/conda/lib/python3.11/site-packages/nvidia/cudnn/lib
CMD ["bash"]

