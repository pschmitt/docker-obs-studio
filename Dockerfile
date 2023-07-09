FROM jlesage/baseimage-gui:ubuntu-22.04-v4

RUN add-pkg locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8

# Install obs-studio
RUN add-pkg --virtual ppa-dependencies software-properties-common gnupg2 && \
    add-apt-repository --yes ppa:obsproject/obs-studio && \
    add-pkg obs-studio stalonetray sudo && \
    del-pkg ppa-dependencies

COPY rootfs/ /
RUN set-cont-env APP_NAME "obs-studio" && \
    set-cont-env APP_VERSION "$(obs --version)"

VOLUME /config
VOLUME /data
