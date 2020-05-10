FROM ubuntu:18.04
USER root
WORKDIR /
RUN useradd -ms /bin/bash openvino && \
    chown openvino -R /home/openvino
ARG DEPENDENCIES="autoconf \
                  automake \
                  build-essential \
                  cmake \
                  cpio \
                  curl \
                  gnupg2 \
                  libdrm2 \
                  libglib2.0-0 \
                  lsb-release \
                  libgtk-3-0 \
                  libtool \
                  python3-pip \
                  udev \
                  unzip \
                  wget"
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ${DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/*
ARG DOWNLOAD_LINK=http://registrationcenter-download.intel.com/akdlm/irc_nas/16612/l_openvino_toolkit_p_2020.2.120.tgz
WORKDIR /tmp
COPY ./l_openvino_toolkit_p_2020.2.120.tgz ./l_openvino_toolkit_p_2020.2.120.tgz
RUN tar -xzf ./l_openvino_toolkit_p_2020.2.120.tgz && \
    cd l_openvino_toolkit_p_2020.2.120 && \
    sed -i 's/decline/accept/g' silent.cfg && \
    ./install.sh -s silent.cfg && \
    rm -rf /tmp/*
ENV INSTALL_DIR /opt/intel/openvino
RUN $INSTALL_DIR/install_dependencies/install_openvino_dependencies.sh

WORKDIR /home
RUN pip3 install --no-cache-dir setuptools jupyter
ENV TINI_VER=v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VER}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
