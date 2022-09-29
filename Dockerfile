FROM ubuntu:20.04

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libtool \
    libvorbis-dev \
    meson \
    nasm \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev \
    # On Ubuntu 20.04
    libunistring-dev \
    libaom-dev \
    fonts-ipafont \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ffmpeg_sources /opt/ffmpeg_build

WORKDIR /opt/ffmpeg_sources
RUN curl -L https://github.com/cisco/openh264/archive/refs/tags/v2.2.0.tar.gz > v2.2.0.tar.gz \
	&& curl -L http://ciscobinary.openh264.org/libopenh264-2.2.0-linux64.6.so.bz2 > libopenh264-2.2.0-linux-arm64.6.so.bz2 \
	&& curl -L https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n4.4.tar.gz > n4.4.tar.gz \
  && tar xf v2.2.0.tar.gz \
  && bunzip2 libopenh264-2.2.0-linux-arm64.6.so.bz2 \
  && tar xf n4.4.tar.gz

WORKDIR /opt/ffmpeg_sources/openh264-2.2.0
RUN make -j `nproc` \
  && make PREFIX="/opt/ffmpeg_build" install-shared

WORKDIR /opt/ffmpeg_sources
RUN cp libopenh264-2.2.0-linux-arm64.6.so /opt/ffmpeg_build/lib/libopenh264.so.2.2.0

WORKDIR /opt/ffmpeg_sources/FFmpeg-n4.4
RUN PKG_CONFIG_PATH="/opt/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="/opt/ffmpeg_build" \
    --enable-libass \
    --enable-libopenh264 \
  && make -j `nproc` \
  && make install

ENV LD_LIBRARY_PATH "/opt/ffmpeg_build/lib:${LD_LIBRARY_PATH}"
ENV PATH "/opt/ffmpeg_build/bin:${PATH}"

ENV USERNAME ffmpeg
ENV HOME /home/${USERNAME}
RUN adduser ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}/
