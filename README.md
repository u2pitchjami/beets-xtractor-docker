![beets-xtractor-docker](https://socialify.git.ci/u2pitchjami/beets-xtractor-docker/image?font=Jost&language=1&logo=https%3A%2F%2Fgreen-berenice-35.tiiny.site%2Fimage2vector-3.svg&name=1&owner=1&pattern=Charlie+Brown&stargazers=1&theme=Dark)

# Beets + Xtractor Docker : Un environnement conteneurisé pour la gestion et l'analyse musicale / A containerized environment for music management and analysis

[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/u2pitchjami/beets-xtractor)](https://hub.docker.com/repository/docker/u2pitchjami/beets-xtractor/general)
![Docker Pulls](https://img.shields.io/docker/pulls/u2pitchjami/beets-xtractor)  
![Docker Image Size](https://img.shields.io/docker/image-size/u2pitchjami/beets-xtractor/latest)  
![GitHub last commit](https://img.shields.io/github/last-commit/u2pitchjami/beets-xtractor-docker)  
![License](https://img.shields.io/github/license/u2pitchjami/beets-xtractor-docker)
![GitHub stars](https://img.shields.io/github/stars/u2pitchjami/beets-xtractor-docker)
![GitHub forks](https://img.shields.io/github/forks/u2pitchjami/beets-xtractor-docker)



Ce projet fournit une solution Docker combinant [Beets](https://beets.io/) et [Essentia](https://essentia.upf.edu/) via le plugin Xtractor pour gérer, analyser et enrichir votre bibliothèque musicale. Grâce à ce conteneur, vous bénéficiez d'une configuration prête à l'emploi pour des tâches complexes comme l'extraction d'attributs audio ou la gestion avancée des métadonnées.

This project provides a Docker solution combining [Beets](https://beets.io/) and [Essentia](https://essentia.upf.edu/) through the Xtractor plugin to manage, analyze, and enrich your music library. With this container, you benefit from a ready-to-use setup for complex tasks such as audio feature extraction or advanced metadata management.

Install Beets + plugins (inline ftintitle discogs bandcamp beatport4 mbsync autogenre lastgenre chroma replaygain keyfinder xtractor lyrics fetchart thumbnails embedart duplicates check missing yearfixer scrub permissions convert export hook describe info fish web )
#bugyplugins : bpsync, acousticbrainz : need url api, badfiles : slowly,

---

## Prérequis / Prerequisites

1. **System:** Linux, Windows, or MacOS with Docker installed.
2. **Tools:**
   - Docker (and Docker Compose if needed)
   - [VSCode](https://code.visualstudio.com/) (optional, but recommended for easier development)

---
## Download and use the Docker image

### Instructions for Docker Hub

1. **Download the Docker image :**

   ```bash
   docker pull u2pitchjami/beets-xtractor:latest
   ```

2. **Start container :**

   ```bash
   docker run --rm -it \
       -v $(pwd)/config:/app/config \
       -v /path/to/music:/app/data \
       -p 8337:8337 \
       <your-dockerhub-username>/beets-xtractor beet <command>
   ```

  For example:

   ```bash
   docker run --rm -it \
       -v $(pwd)/config:/app/config \
       -v /path/to/music:/app/data \
       -p 8337:8337 \
       <your-dockerhub-username>/beets-xtractor beet import /app/data
   ```

## Using Docker Compose

Here is an example `docker-compose.yml` file for this project:

```yaml
services:
  beets:
    image: u2pitchjami/beets-xtractor
    container_name: beets-xtractor
    network_mode: bridge
    ports:
      - "8337:8337"
    volumes:
      - ./config:/app/config
      - /path/to/music:/app/data
    environment:
      BEETSDIR: /app/config
      tty: true
```

### How to Use

1. **Make your config.yalm and place it in /config (see config.yalm.example)**
   
2. **Take your music in /data or make another link docker compose**

2. **Start the Container**
   ```bash
   docker-compose up -d
   ```

4. **Run Beets Commands**
   To run a Beets command, use the following syntax:
   ```bash
   docker-compose run --rm beets beet <command>
   ```
   For example:
   ```bash
   docker-compose run --rm beets beet import /app/data
   ```

## Using Bash Alias

For ease of use, you can create a Bash alias to simplify running Beets commands. Add the following line to your `.bashrc` or `.zshrc` file:

```bash
alias beet-docker='docker-compose run --rm -p 8443:8337 beets beet'
```

After adding this alias, reload your shell configuration:

```bash
source ~/.bashrc
```

Now, you can use the alias to run Beets commands directly. For example:

```bash
beet-docker import /app/data
```

Si vous avez des questions ou des améliorations à suggérer, n'hésitez pas à ouvrir une issue ou une pull request sur le dépôt GitHub !  
If you have questions or improvements to suggest, feel free to open an issue or pull request on the GitHub repository!


## Project Structure

Here is the recommended project structure:

```
beets-xtractor-docker/
├── Dockerfile
├── docker-compose.yml (facultatif / optional)
├── config/
│   ├── config.yaml
│   └── other-config-files
├── scripts/
│   └── entrypoint.sh
├── assets/
│   ├── essentia-2.1_beta5.tar.gz
│   ├── eigen-3.4.0.tar.gz
│   ├── swig-3.0.12.tar.gz
│   ├── essentia-extractor-svm_models-v2.1_beta5.tar.gz
└── README.md
```

**Description of elements:**

- **Dockerfile:** Instructions to build the Docker image.
- **config/**: Contains configuration files for Beets.
- **scripts/**: Contains automation scripts (e.g., `entrypoint.sh`).
- **assets/**: Contains source files required for the project (like Essentia, Eigen, SWIG, Gaia, and Eiden).
- **data/**: Shared folder where audio files to process will be placed.
- **README.md:** Explanatory documentation for GitHub.

---

## Creating the Dockerfile

Here is the content of the `Dockerfile`:

```dockerfile
# Base image
FROM debian:bullseye-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip python3-gi \
    cmake build-essential \
    wget git pkg-config \
    ffmpeg mp3val flac \
    libpcre3-dev \
    libyaml-dev qtbase5-dev \
    libfftw3-dev libavcodec-dev libavformat-dev libavresample-dev libswresample-dev libavutil-dev libtag1-dev libchromaprint-dev libsamplerate0-dev \
    libcairo2-dev \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && qmake --version \
    && ffmpeg -version \
    && rm -rf /var/lib/apt/lists/*

# Add python alias for waf compatibility
ENV CXXFLAGS="-I/usr/local/include/eigen3"



# Set working directory
WORKDIR /app

# Install SWIG
COPY assets/swig-3.0.12.tar.gz /app/
RUN cd /app \
    && tar -xzf swig-3.0.12.tar.gz \
    && cd swig-3.0.12 \
    && ./configure \
    && make \
    && make install \
    && rm -rf /app/swig-3.0.12 /app/swig-3.0.12.tar.gz
    
# Install Eigen
COPY assets/eigen-3.4.0.tar.gz /app/
RUN cd /app \
    && tar -xzf eigen-3.4.0.tar.gz \
    && cd eigen-3.4.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \
    && rm -rf /app/eigen-3.4.0 /app/eigen-3.4.0.tar.gz
# Install Gaia from GitHub
RUN git clone https://github.com/MTG/gaia.git /app/gaia \
    && cd /app/gaia \
    && ./waf configure --with-python-bindings --with-asserts \
    && ./waf build \
    && ./waf install \
    && ldconfig \
    && rm -rf /app/gaia

# Extract and build Essentia + SVM models for Essentia
COPY assets/essentia-2.1_beta5.tar.gz /app/
COPY assets/essentia-extractor-svm_models-v2.1_beta5.tar.gz /app/
RUN pip3 install numpy==1.19.5 pycairo \
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

 # Install ImageMagick from source
RUN cd /app \
    && wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
    && tar -xzf ImageMagick.tar.gz \
    && cd ImageMagick-* \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /app/ImageMagick.tar.gz /app/ImageMagick-*

    # Install libkeyfinder dependency
RUN git clone https://github.com/mixxxdj/libkeyfinder.git /app/libkeyfinder \
    && cd /app/libkeyfinder \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -S . -B build \
    && cmake --build build --parallel $(nproc) \
    && cmake --install build \
    && ldconfig \
    && rm -rf /app/libkeyfinder

# Install Keyfinder from GitHub
RUN git clone https://github.com/evanpurkhiser/keyfinder-cli.git /app/keyfinder-cli \
    && cd /app/keyfinder-cli \
    && git submodule update --init --recursive \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /app/keyfinder-cli

# Install Beets
RUN pip3 install beets==2.1.0 \
    Flask requests-oauthlib \
    beets[fetchart,thumbnails,embedart,scrub,lyrics,autobpm,discog,replaygain,chroma,web] \
    discogs_client beets-beatport4 beets-xtractor beetcamp beets-yearfixer beets-describe beets-check \
    && python3 -m pip install beets-autogenre
    
# Copy default config
COPY config/config.yaml.example /app/default_config/config.yaml
COPY config/beatport_credentials.yaml.example /app/default_config/beatport_credentials.yaml

# Set entrypoint script
COPY scripts/entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/app/entrypoint.sh"]

# Adding usage instruction for Docker Hub
LABEL org.opencontainers.image.source https://github.com/u2pitchjami/beets-xtractor-docker
LABEL org.opencontainers.image.description "Dockerized Beets + Xtractor setup"
LABEL org.opencontainers.image.licenses "MIT"
```

---
## Authors

👤 **u2pitchjami**

[![Bluesky](https://img.shields.io/badge/Bluesky-Follow-blue?logo=bluesky)](https://bsky.app/profile/u2pitchjami.bsky.social)
[![Twitter](https://img.shields.io/twitter/follow/u2pitchjami.svg?style=social)](https://twitter.com/u2pitchjami)
![GitHub followers](https://img.shields.io/github/followers/u2pitchjami)
![Reddit User Karma](https://img.shields.io/reddit/user-karma/combined/u2pitchjami)

* Twitter: [@u2pitchjami](https://twitter.com/u2pitchjami)
* Github: [@u2pitchjami](https://github.com/u2pitchjami)
* LinkedIn: [@LinkedIn](https://linkedin.com/in/thierry-beugnet-a7761672)
