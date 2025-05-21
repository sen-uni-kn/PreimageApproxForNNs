FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    m4 \
    cmake \
    autoconf \
    libgmp-dev \
    libgmpxx4ldbl \
    libmpfr-dev \
    libmpc-dev \
    libppl-dev \
    libpari-dev \
    libhdf5-dev \
    libhdf5-103-1 \
    protobuf-compiler \
    libprotobuf-dev \
    libprotoc-dev \
    cython3 \
    python3-gmpy2 \
    python3-cysignals-pari \
    libtool \
    pkg-config \
    python3-pip \
    python3-setuptools \
    python3-dev \
    python3-distutils \
    && apt-get clean \
    && find /usr/lib/x86_64-linux-gnu -name "libprotobuf.a" -delete

# Install latest pip
RUN python3 -m pip install --upgrade pip

# ---------- Build GMP 6.2.1 from source ----------
WORKDIR /opt
RUN wget https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz \
 && tar -xf gmp-6.2.1.tar.xz \
 && cd gmp-6.2.1 \
 && ./configure --prefix=/usr/local \
 && make -j$(nproc) \
 && make install \
 && ldconfig

# Install PPL from source
WORKDIR /opt
RUN wget https://www.bugseng.com/products/ppl/download/ftp/releases/1.2/ppl-1.2.tar.gz \
 && tar -xzf ppl-1.2.tar.gz \
 && cd ppl-1.2 \
 && ./configure --prefix=/usr/local \
 && make -j$(nproc) \
 && make install \
 && ldconfig

# Clone and install pplpy==0.8.7
WORKDIR /opt
RUN git clone https://github.com/videlec/pplpy.git \
 && cd pplpy \
 && git checkout 486e5c1 \
 && python3 setup.py build \
 && python3 setup.py install

# Test installation
RUN python3 -c "import ppl; p = ppl.NNC_Polyhedron(2, 'universe'); print(p)"

# Install Python Packages
WORKDIR /opt
RUN python3 -m pip install "setuptools==61.2.0" "pip==21.2.2" \
 && python3 -m pip install \
    "absl-py==0.15.0" "cloudpickle==2.0.0" "gurobipy==9.5.1" "h5py==2.10.0" \
    "matplotlib==3.5.1" "numpy==1.21.5" "onnx>=1.11.0" --prefer-binary \
    "onnxruntime>=1.11.0" "pandas==1.3.4" "sortedcontainers==2.4.0" \
    "pillow==9.0.1" "psutil==5.8.0" "torch==1.11.0" "pyyaml==6.0" \
    "requests==2.27.1" "scipy==1.7.3" "tensorboard==2.6.0" \
    "torchaudio==0.11.0" "torchvision==0.12.0" "tqdm==4.64.0" \
    "appdirs>=1.4.4" "packaging>=21.3" \
    "git+https://github.com/Verified-Intelligence/onnx2pytorch.git"

# Prepare VCAS Experiment
ADD . /opt/PreimageApproxForNNs
WORKDIR /opt/PreimageApproxForNNs/src

CMD [ "python3", "preimage_main.py", "--config", "preimg_configs/vcas.yaml" ]
