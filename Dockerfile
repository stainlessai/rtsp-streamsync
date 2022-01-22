FROM ubuntu:18.04 as builder

ENV HOME "/home"

RUN apt-get update && \
  apt-get install -y \
    git && \
    rm -rf /var/lib/apt/lists/*

###############################################################################
#
#							mv-extractor library (legacy version)
#
###############################################################################

# Build h264-videocap from source
RUN cd $HOME && git clone -b python_3.8 https://github.com/stainlessai/mv-extractor.git video_cap 

RUN cd $HOME/video_cap && \
  chmod +x install.sh && \
  ./install.sh

FROM ubuntu:20.04

ENV HOME "/home"
ENV DEBIAN_FRONTEND "noninteractive"
ENV TZ "America/Los_Angeles"

# copy libraries
WORKDIR /usr/local/lib
COPY --from=builder /usr/local/lib .
WORKDIR /usr/local/include
COPY --from=builder /home/ffmpeg_build/include .
WORKDIR /home/ffmpeg_build/lib
COPY --from=builder /home/ffmpeg_build/lib .
WORKDIR /usr/local/include/opencv4/
COPY --from=builder /usr/local/include/opencv4/ .
WORKDIR /home/opencv/build/lib
COPY --from=builder /home/opencv/build/lib .
WORKDIR /home/video_cap
COPY --from=builder /home/video_cap .

# Set environment variables
ENV PATH "$PATH:$HOME/bin"
ENV PKG_CONFIG_PATH "$PKG_CONFIG_PATH:$HOME/ffmpeg_build/lib/pkgconfig"

# install Python
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-pkgconfig \
    libgtk-3-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libmp3lame-dev \
    zlib1g-dev \
    libx264-dev \
    libsdl2-dev \
    libvpx-dev \
    libvdpau-dev \
    libvorbis-dev \
    libopus-dev \
    libdc1394-22-dev \
    liblzma-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cd $HOME/video_cap && \
    python3 setup.py install

###############################################################################
#
#							Python stream-sync module
#
###############################################################################

WORKDIR $HOME/stream_sync

COPY setup.py $HOME/stream_sync
COPY src $HOME/stream_sync/src/

# Install stream_sync Python module
RUN cd /home/stream_sync && \
  python3 setup.py install

WORKDIR $HOME

CMD ["sh", "-c", "tail -f /dev/null"]
