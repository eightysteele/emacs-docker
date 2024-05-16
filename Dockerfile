################################################################################
FROM ubuntu:jammy AS base
################################################################################

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    gnupg \
    git \
    libncurses5-dev \
    libgnutls28-dev \
    libxml2-dev \
    xorg-dev \
    libgtk-3-dev \
    libharfbuzz-dev libxaw7-dev \
    libxpm-dev \
    libpng-dev \
    zlib1g-dev \
    libjpeg-dev \
    libtiff-dev \
    libgif-dev \
    librsvg2-dev \
    libwebp-dev \
    imagemagick \
    libmagickwand-dev \
    libwebkit2gtk-4.0-dev \
    libgccjit-11-dev \
    libjansson-dev \
    fonts-firacode \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################################################
FROM base AS build-emacs
################################################################################

ADD scripts/build-emacs.sh /usr/local/bin
RUN build-emacs.sh

################################################################################
FROM build-emacs AS build-spacemacs
################################################################################

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    curl \
    fonts-firacode \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build-emacs /usr/local /usr/local
ADD scripts/utils.sh /usr/local/bin

ARG USERNAME
ARG UID
ARG GID
ADD scripts/create-user.sh /usr/local/bin
RUN create-user.sh

USER $USERNAME
WORKDIR /home/${USERNAME}

ARG SPACEMACS_D_REPO
ADD scripts/build-spacemacs.sh /usr/local/bin
RUN build-spacemacs.sh

ADD scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#CMD ["bash"]

# ARG ORG_TOKEN
# ARG ORG_REPO
# RUN clone-org-data.sh
# RUN build-haskell.sh

# USER root
# ADD build-shellcheck.sh /usr/local/bin
# USER $USERNAME
# RUN build-shellcheck.sh

# USER root
# ADD build-node.sh /usr/local/bin
# USER $USERNAME
# RUN build-node.sh

# USER root
# ADD build-docker-lsp-server.sh /usr/local/bin
# USER $USERNAME
# RUN build-docker-lsp-server.sh

# USER root
# ADD build-ghcup.sh /usr/local/bin
# USER $USERNAME
# RUN build-ghcup.sh


# ################################################################################
# FROM base AS setup-user
# ################################################################################

# ARG USERNAME
# ARG UID
# ARG GID
# ADD setup-user.sh /usr/local/bin
# RUN setup-user.sh

# ################################################################################
# FROM setup-user AS build-emacs
# ################################################################################

# ADD build-emacs.sh /usr/local/bin
# RUN build-emacs.sh

# ################################################################################
# FROM build-emacs AS setup-emacs
# ################################################################################

# ARG ORG_TOKEN
# ARG ORG_REPO
# ARG USERNAME
# ARG HOME_DIR=/home/${USERNAME}
# USER $USERNAME
# WORKDIR $HOME_DIR
# ADD setup-emacs.sh /usr/local/bin
# RUN setup-emacs.sh

# ################################################################################
# FROM setup-emacs AS install-spacemacs
# ################################################################################

# ADD install-spacemacs.sh /usr/local/bin
# ARG USERNAME
# ARG HOME_DIR=/home/${USERNAME}
# WORKDIR $HOME_DIR
# RUN install-spacemacs.sh

# ################################################################################
# FROM install-spacemacs AS entrypoint
# ################################################################################

# ARG USERNAME
# ARG HOME_DIR=/home/${USERNAME}
# COPY --from=install-spacemacs ${HOME_DIR}/.emacs.d ${HOME_DIR}/.emacs.d
# WORKDIR $HOME_DIR
# ADD install-layer-deps.sh /usr/local/bin
# USER ${USERNAME}
# RUN install-layer-deps.sh
# RUN echo 'export PS1="\u@\h (docker):\w\$ "' >> ${HOME_DIR}/.bashrc
