# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

FROM ubuntu:16.04

USER root:root

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Update base container install
RUN apt-get update
RUN apt-get upgrade -y

# Add unstable repo to allow us to access latest GDAL builds
RUN echo deb http://ftp.uk.debian.org/debian unstable main contrib non-free >> /etc/apt/sources.list
RUN apt-get update

# Existing binutils causes a dependency conflict, correct version will be installed when GDAL gets intalled
RUN apt-get remove -y binutils

# Install GDAL dependencies
RUN apt-get -t unstable install -y libgdal-dev g++

RUN apt install -y gdal-bin python-gdal python3-gdal



# Update C env vars so compiler can find gdal
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# This will install GDAL 2.2.4
RUN pip install GDAL==2.2.4

RUN pip install numpy pandas argparse multiprocess tqdm sklearn gdal rasterio learn2map

# Install Common Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # SSH and RDMA
    libmlx4-1 \
    libmlx5-1 \
    librdmacm1 \
    libibverbs1 \
    libmthca1 \
    libdapl2 \
    dapl2-utils \
    openssh-client \
    openssh-server \
    iproute2 && \
    # Others
    apt-get install -y \
    build-essential \
    bzip2 \
    git=1:2.7.4-0ubuntu1.6 \
    wget \
    cpio && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Conda Environment
ENV MINICONDA_VERSION 4.5.11
ENV PATH /opt/miniconda/bin:$PATH
RUN wget -qO /tmp/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -bf -p /opt/miniconda && \
    conda clean -ay && \
    rm -rf /opt/miniconda/pkgs && \
    rm /tmp/miniconda.sh && \
    find / -type d -name __pycache__ | xargs rm -rf

RUN conda install pytables

# Intel MPI installation
ENV INTEL_MPI_VERSION 2018.3.222
ENV PATH $PATH:/opt/intel/compilers_and_libraries/linux/mpi/bin64
RUN cd /tmp && \
    wget -q "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13063/l_mpi_${INTEL_MPI_VERSION}.tgz" && \
    tar zxvf l_mpi_${INTEL_MPI_VERSION}.tgz && \
    sed -i -e 's/^ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' /tmp/l_mpi_${INTEL_MPI_VERSION}/silent.cfg && \
    cd /tmp/l_mpi_${INTEL_MPI_VERSION} && \
    ./install.sh -s silent.cfg --arch=intel64 && \
    cd / && \
    rm -rf /tmp/l_mpi_${INTEL_MPI_VERSION}* && \
    rm -rf /opt/intel/compilers_and_libraries_${INTEL_MPI_VERSION}/linux/mpi/intel64/lib/debug* && \
    echo "source /opt/intel/compilers_and_libraries_${INTEL_MPI_VERSION}/linux/mpi/intel64/bin/mpivars.sh" >> ~/.bashrc
