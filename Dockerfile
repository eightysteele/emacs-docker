################################################################################
FROM ubuntu:jammy AS base
################################################################################

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    sudo

################################################################################
FROM base AS setup-user
################################################################################

ARG USERNAME
ARG UID
ARG GID
ADD setup-user.sh /usr/local/bin
RUN setup-user.sh

################################################################################
FROM setup-user AS build-emacs
################################################################################

ADD build-emacs.sh /usr/local/bin
RUN build-emacs.sh

################################################################################
FROM build-emacs AS setup-emacs
################################################################################

ARG ORG_TOKEN
ARG ORG_REPO
ARG USERNAME
ARG HOME_DIR=/home/${USERNAME}
USER $USERNAME
WORKDIR $HOME_DIR
ADD setup-emacs.sh /usr/local/bin
RUN setup-emacs.sh

################################################################################
FROM setup-emacs AS install-spacemacs
################################################################################

ADD install-spacemacs.sh /usr/local/bin
ARG USERNAME
ARG HOME_DIR=/home/${USERNAME}
WORKDIR $HOME_DIR
RUN install-spacemacs.sh

################################################################################
FROM install-spacemacs AS entrypoint
################################################################################

ARG USERNAME
ARG HOME_DIR=/home/${USERNAME}
COPY --from=install-spacemacs ${HOME_DIR}/.emacs.d ${HOME_DIR}/.emacs.d
WORKDIR $HOME_DIR
ADD install-layer-deps.sh /usr/local/bin
USER ${USERNAME}
RUN install-layer-deps.sh
RUN echo 'export PS1="\u@\h (docker):\w\$ "' >> ${HOME_DIR}/.bashrc
