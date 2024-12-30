# Base image
FROM debian:bullseye-slim

# Install system dependencies
COPY assets/* /app/
RUN apt-get update && apt-get install -y \
    python3-pip python3-gi \
    wget git \
    mp3val flac \
    libpcre3-dev \
    # for Gaia :
    qtbase5-dev pkg-config libtag1-dev \
    # for Gaia & chroma plugin :
    libchromaprint-dev \
    # for Gaia & Essentia :
    python3-dev libyaml-dev build-essential \
    # for Essentia :
    yasm python3-numpy-dev python3-six ffmpeg libavcodec-dev libavformat-dev libswresample-dev libavutil-dev libsamplerate0-dev \
    #for Essentia & librekey
    cmake libfftw3-dev \
    libavresample-dev \
    libcairo2-dev \
    # for Magick
    libjpeg-dev libpng-dev libtiff-dev libwebp-dev libtool libxml2-dev libfontconfig-dev libfreetype6-dev liblcms2-dev libopenexr-dev libx11-dev libxext-dev libxt-dev \
    # for Essentia :
    && pip3 install numpy==1.19.5 pycairo==1.20.1 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && qmake --version \
    && ffmpeg -version \
    && rm -rf /var/lib/apt/lists/*

# Add python alias for waf compatibility
ENV CXXFLAGS="-I/usr/local/include/eigen3"
# Set working directory
WORKDIR /app
# Install SWIG for Gaia
RUN cd /app \
    && tar -xzf swig-3.0.12.tar.gz \
    && cd swig-3.0.12 \
    && ./configure \
    && make \
    && make install \
    && rm -rf /app/swig-3.0.12 /app/swig-3.0.12.tar.gz \
# Install Eigen for Gaia & Essentia
    && cd /app \
    && tar -xzf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \
    && rm -rf /app/eigen-3.4.0 /app/eigen-3.4.0.tar.gz \
    && cd /app \
# Install Gaia from GitHub
    && git clone https://github.com/MTG/gaia.git /app/gaia \
    && cd /app/gaia \
    && ./waf configure --with-python-bindings --with-asserts \
    && ./waf build \
    && ./waf install \
    && ldconfig \
    && rm -rf /app/gaia \
    && cd /app \
# Extract and build Essentia + SVM models for Essentia
    && cd /app \
    && tar -xzf essentia-2.1_beta5.tar.gz \
    && cd essentia-2.1_beta5 \
    && wget https://waf.io/waf-2.0.23 \
    && mv waf-2.0.23 waf \
    && chmod +x waf \
    && ./waf configure --build-static --with-python --with-examples --with-gaia \
    && ./waf build \
    && ./waf install \
    && ldconfig \
    && cd /app \
    && mkdir -p /app/default_config/svm_models \
    && tar -xzf essentia-extractor-svm_models-v2.1_beta5.tar.gz \
    && cp -r essentia-extractor-svm_models-v2.1_beta5/* /app/default_config/svm_models/ \
    && rm -rf /app/essentia-extractor-svm_models-v2.1_beta5 /app/essentia-extractor-svm_models-v2.1_beta5.tar.gz \
    && rm -rf /app/essentia-2.1_beta5 /app/essentia-2.1_beta5.tar.gz

 # Install ImageMagick from source for fetchart & thumbnails & embedart
RUN cd /app \
    && wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
    && tar -xzf ImageMagick.tar.gz \
    && cd ImageMagick-* \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /app/ImageMagick.tar.gz /app/ImageMagick-* \
    && cd /app \
    # Install libkeyfinder dependency for Keyfinder-cli
    && git clone https://github.com/mixxxdj/libkeyfinder.git /app/libkeyfinder \
    && cd /app/libkeyfinder \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -S . -B build \
    && cmake --build build --parallel $(nproc) \
    && cmake --install build \
    && ldconfig \
    && rm -rf /app/libkeyfinder \
    && cd /app \
# Install Keyfinder from GitHub
    && git clone https://github.com/evanpurkhiser/keyfinder-cli.git /app/keyfinder-cli \
    && cd /app/keyfinder-cli \
    && git submodule update --init --recursive \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /app/keyfinder-cli
COPY scripts/keyfinder-camelot.sh /bin/
# Install Beets
RUN pip3 install beets \
    beets[fetchart,thumbnails,embedart,scrub,lyrics,autobpm,discog,replaygain,chroma,web] \
    beets-beatport4 beets-xtractor beetcamp beets-yearfixer beets-describe beets-check \
    #for web plugin
    Flask \
    # for discogs
    python3-discogs-client requests-oauthlib \
    # for autobpm
    && python -m pip install librosa \
    && python3 -m pip install beets-autogenre
    
# Copy default config
COPY config/config.yaml.example /app/default_config/config.yaml
COPY config/beatport_credentials.yaml.example /app/default_config/beatport_credentials.yaml

# Set entrypoint script
COPY scripts/entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh \
    && chmod +x /bin/keyfinder-camelot.sh \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/app/entrypoint.sh"]