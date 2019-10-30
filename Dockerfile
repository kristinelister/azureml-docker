FROM debian:latest


#Mostly copied from https://hub.docker.com/r/continuumio/miniconda/dockerfile :)
#added some gdal and other packages

#  $ docker build . -t continuumio/miniconda:latest -t continuumio/miniconda:4.5.11 -t continuumio/miniconda2:latest -t continuumio/miniconda2:4.5.11
#  $ docker run --rm -it continuumio/miniconda2:latest /bin/bash
#  $ docker push continuumio/miniconda:latest
#  $ docker push continuumio/miniconda:4.5.11
#  $ docker push continuumio/miniconda2:latest
#  $ docker push continuumio/miniconda2:4.5.11

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean


RUN apt-get install python3-pip python3-dev build-essential -y
RUN pip3 install --upgrade pip


RUN apt-get install -y binutils libproj-dev gdal-bin libgdal-dev 
RUN apt-get -y install python-gdal

RUN export CPLUS_INCLUDE_PATH=/usr/include/gdal

RUN export C_INCLUDE_PATH=/usr/include/gdal

RUN conda install -c conda-forge pytables gdal numpy pandas rasterio

#RUN pip3 install GDAL==2.2.4



RUN pip3 install argparse multiprocess tqdm sklearn learn2map


ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
