# Base image
FROM debian:bullseye-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    mp3val \
    flac \
    python3 python3-pip python3-dev \
    build-essential \
    cmake \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavresample-dev \
    libswresample-dev \
    libavutil-dev \
    git \
    wget \
    libfftw3-dev \
    libyaml-dev \
    libmagic-dev \
    imagemagick \
    libsndfile-dev \
    zlib1g-dev \
    libsqlite3-dev \
    libjpeg-dev \
    libxml2-dev \
    libxslt1-dev \
    qtbase5-dev qttools5-dev-tools \
    libpcre3-dev \
    libtag1-dev \
    libcairo2 \
    libcairo2-dev \
    pkg-config \
    libcairo2 \
    libcairo2-dev \
    pkg-config \
    libsamplerate0-dev \
    libchromaprint-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gir1.2-gstreamer-1.0 \
    gir1.2-gst-plugins-base-1.0 \
    python3-gi \
    && qmake --version \
    && ffmpeg -version \
    && rm -rf /var/lib/apt/lists/*

# Add python alias for waf compatibility
ENV CXXFLAGS="-I/usr/local/include/eigen3"
RUN pip3 install numpy==1.19.5 \
    pycairo
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Install SWIG
COPY assets/swig-3.0.12.tar.gz /app/
RUN cd /app \
    && tar -xzf swig-3.0.12.tar.gz \
    && cd swig-3.0.12 \
    && ./configure \
    && make \
    && make install

# Install Eigen
COPY assets/eigen-3.4.0.tar.gz /app/
RUN cd /app \
    && tar -xzf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install

# Install Gaia from GitHub
RUN git clone https://github.com/MTG/gaia.git /app/gaia \
    && cd /app/gaia \
    && ./waf configure --with-python-bindings --with-asserts \
    && ./waf build \
    && ./waf install \
    && ldconfig

# Copy Essentia source code and models from local assets
COPY assets/essentia-2.1_beta5.tar.gz /app/
COPY assets/essentia-extractor-svm_models-v2.1_beta5.tar.gz /app/

# Extract SVM models for Essentia
RUN mkdir -p /data/config/svm_models \
    && cd /app \
    && tar -xzf essentia-extractor-svm_models-v2.1_beta5.tar.gz \
    && cp -r essentia-extractor-svm_models-v2.1_beta5/* /data/config/svm_models/

# Extract and build Essentia
RUN cd /app \
    && tar -xzf essentia-2.1_beta5.tar.gz \
    && cd essentia-2.1_beta5 \
    && wget https://waf.io/waf-2.0.23 \
    && mv waf-2.0.23 waf \
    && chmod +x waf \
    && ./waf configure --with-python --with-examples --with-gaia \
    && ./waf build \
    && ./waf install \
    && ldconfig

# Install ImageMagick from source
RUN apt-get update && apt-get install -y \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libtool \
    libxml2-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenexr-dev \
    libx11-dev \
    libxext-dev \
    libxt-dev \
    && cd /app \
    && wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
    && tar -xzf ImageMagick.tar.gz \
    && cd ImageMagick-* \
    && ./configure \
    && make \
    && make install \
    && ldconfig

# Install libkeyfinder dependency
RUN apt-get update && apt-get install -y \
    cmake \
    libfftw3-dev \
    && git clone https://github.com/mixxxdj/libkeyfinder.git /app/libkeyfinder \
    && cd /app/libkeyfinder \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -S . -B build \
    && cmake --build build --parallel $(nproc) \
    && cmake --install build \
    && ldconfig

# Install Keyfinder from GitHub
RUN git clone https://github.com/evanpurkhiser/keyfinder-cli.git /app/keyfinder-cli \
    && cd /app/keyfinder-cli \
    && git submodule update --init --recursive \
    && make \
    && make install \
    && ldconfig

# Copy Beatport credentials
COPY config/beatport_credentials.yaml /app/config/

# Install Beets
RUN pip3 install beets==2.1.0 \
    beets[fetchart] \
    beets[embedart] \
    beets[scrub] \
    beets[lyrics] \
    beets[lastgenre] \
    beets[autobpm] \
    beets[discogs] \
    discogs_client \
    beets-beatport4 \
    beets-xtractor \
    beets[replaygain] \
    beets[chroma] \
    Flask \
    beets[web] \
    requests-oauthlib

EXPOSE 8337    

# Set entrypoint script
COPY scripts/entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]