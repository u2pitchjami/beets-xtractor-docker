![beets-xtractor-docker](https://socialify.git.ci/u2pitchjami/beets-xtractor-docker/image?font=Jost&language=1&logo=https%3A%2F%2Fgreen-berenice-35.tiiny.site%2Fimage2vector-3.svg&name=1&owner=1&pattern=Charlie+Brown&stargazers=1&theme=Dark)

# Beets + Xtractor Docker : Un environnement conteneurisé pour la gestion et l'analyse musicale / A containerized environment for music management and analysis

[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/u2pitchjami/beets-xtractor)](https://hub.docker.com/repository/docker/u2pitchjami/beets-xtractor/general)
![GitHub stars](https://img.shields.io/github/stars/u2pitchjami/beets-xtractor-docker)
![GitHub forks](https://img.shields.io/github/forks/u2pitchjami/beets-xtractor-docker)



Ce projet fournit une solution Docker combinant [Beets](https://beets.io/) et [Essentia](https://essentia.upf.edu/) via le plugin Xtractor pour gérer, analyser et enrichir votre bibliothèque musicale. Grâce à ce conteneur, vous bénéficiez d'une configuration prête à l'emploi pour des tâches complexes comme l'extraction d'attributs audio ou la gestion avancée des métadonnées.

This project provides a Docker solution combining [Beets](https://beets.io/) and [Essentia](https://essentia.upf.edu/) through the Xtractor plugin to manage, analyze, and enrich your music library. With this container, you benefit from a ready-to-use setup for complex tasks such as audio feature extraction or advanced metadata management.

---

## Prérequis / Prerequisites

1. **Système :** Linux, Windows, ou MacOS avec Docker installé.  
   **System:** Linux, Windows, or MacOS with Docker installed.
2. **Outils :**  
   **Tools:**
   - Docker (et Docker Compose si nécessaire)  
     Docker (and Docker Compose if needed)
   - [VSCode](https://code.visualstudio.com/) (optionnel, mais recommandé pour un développement facilité)  
     [VSCode](https://code.visualstudio.com/) (optional, but recommended for easier development)
3. **Accès à Internet** pour télécharger les dépendances.  
   **Internet access** to download dependencies.

---

## Structure du projet / Project Structure

Voici la structure recommandée pour le projet :  
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

**Description des éléments :**  
**Description of elements:**

- **Dockerfile :** Instructions pour créer l’image Docker.  
  **Dockerfile:** Instructions to build the Docker image.
- **config/** : Contient les fichiers de configuration pour Beets.  
  **config/**: Contains configuration files for Beets.
- **scripts/** : Contient des scripts d’automatisation (par exemple `entrypoint.sh`).  
  **scripts/**: Contains automation scripts (e.g., `entrypoint.sh`).
- **assets/** : Contient les fichiers sources nécessaires au projet (comme Essentia, Eigen, SWIG, Gaia, et Eiden).  
  **assets/**: Contains source files required for the project (like Essentia, Eigen, SWIG, Gaia, and Eiden).
- **data/** : Dossier partagé où seront placés les fichiers audio à traiter.  
  **data/**: Shared folder where audio files to process will be placed.
- **README.md :** Documentation explicative pour GitHub.  
  **README.md:** Explanatory documentation for GitHub.

---

## Création du Dockerfile / Creating the Dockerfile

Voici le contenu du fichier `Dockerfile` :  
Here is the content of the `Dockerfile`:

```dockerfile
# Base image
FROM debian:bullseye-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    build-essential \
    cmake \
    ffmpeg \
    git \
    wget \
    libfftw3-dev \
    libyaml-dev \
    libmagic-dev \
    imagemagick \
    libsndfile-dev \
    zlib1g-dev \
    libavcodec-dev \
    libavformat-dev \
    libswresample-dev \
    libsqlite3-dev \
    libjpeg-dev \
    libxml2-dev \
    libxslt1-dev \
    qtbase5-dev qttools5-dev-tools \
    libpcre3-dev \
    libcairo2 \
    libcairo2-dev \
    pkg-config \
    gstreamer1.0-tools \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gir1.2-gstreamer-1.0 \
    gir1.2-gst-plugins-base-1.0 \
    && rm -rf /var/lib/apt/lists/*

# Add python alias for waf compatibility
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python dependencies
RUN pip3 install numpy==1.19.5 pycairo requests-oauthlib \
    beets==2.1.0 \
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
    beets[web]

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

# Set entrypoint script
COPY scripts/entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Expose the port used by the web plugin
EXPOSE 8337

ENTRYPOINT ["/app/entrypoint.sh"]

# Adding usage instruction for Docker Hub
LABEL org.opencontainers.image.source https://github.com/u2pitchjami/beets-xtractor-docker
LABEL org.opencontainers.image.description "Dockerized Beets + Xtractor setup"
LABEL org.opencontainers.image.licenses "MIT"
```

---

## Télécharger et utiliser l'image Docker / Download and use the Docker image

### Instructions pour Docker Hub / Instructions for Docker Hub

1. **Télécharger l'image :**

   ```bash
   docker pull u2pitchjami/beets-xtractor
   ```

2. **Lancer un conteneur :**

   ```bash
   docker run --rm -it \
       -v $(pwd)/config:/app/config \
       -v /path/to/music:/app/data \
       -p 8337:8337 \
       <your-dockerhub-username>/beets-xtractor beet <command>
   ```

   Par exemple / For example:

   ```bash
   docker run --rm -it \
       -v $(pwd)/config:/app/config \
       -v /path/to/music:/app/data \
       -p 8337:8337 \
       <your-dockerhub-username>/beets-xtractor beet import /app/data
   ```

Si vous avez des questions ou des améliorations à suggérer, n'hésitez pas à ouvrir une issue ou une pull request sur le dépôt GitHub !  
If you have questions or improvements to suggest, feel free to open an issue or pull request on the GitHub repository!

## Authors

👤 **u2pitchjami**

[![Bluesky](https://img.shields.io/badge/Bluesky-Follow-blue?logo=bluesky)](https://bsky.app/profile/u2pitchjami.bsky.social)
[![Twitter](https://img.shields.io/twitter/follow/u2pitchjami.svg?style=social)](https://twitter.com/u2pitchjami)
![GitHub followers](https://img.shields.io/github/followers/u2pitchjami)
![Reddit User Karma](https://img.shields.io/reddit/user-karma/combined/u2pitchjami)

* Twitter: [@u2pitchjami](https://twitter.com/u2pitchjami)
* Github: [@u2pitchjami](https://github.com/u2pitchjami)
* LinkedIn: [@LinkedIn](https://linkedin.com/in/thierry-beugnet-a7761672)