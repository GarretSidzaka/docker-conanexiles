FROM ubuntu:24.04

LABEL maintainer="GarretSidzaka"

ENV TIMEZONE=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    CONANEXILES_MASTERSERVER=1 \
    CONANEXILES_Game_RconPlugin_RconEnabled=1 \
    CONANEXILES_Game_RconPlugin_RconPassword=Password \
    CONANEXILES_Game_RconPlugin_RconPort=25575 \
    CONANEXILES_Game_RconPlugin_RconMaxKarma=60 \
    CONANEXILES_Engine_Core.Log_LogStreaming=Warning \
    CONANEXILES_Engine_Core.Log_LogModController=Warning \
    CONANEXILES_Engine_Core.Log_LoglevelActorContainer=Warning \
    CONANEXILES_Game_/Script/ConanSandbox.ConanGameMode_PeriodicBackupInterval=900

RUN apt-get update \
    && apt-get install -y crudini python3-pip redis-tools software-properties-common supervisor unzip curl xvfb wget rsync net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN dpkg --add-architecture i386 \
    && curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/' \
    && apt-get update \
    && apt-get install --install-recommends --assume-yes winehq-devel \
    && pip3 install python-valve --break-system-packages \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install winetricks
ADD https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks /usr/bin/winetricks
RUN chmod +rx /usr/bin/winetricks

RUN apt-get update \
    && apt-get install -y x11vnc strace cabextract \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . ./

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +rx /entrypoint.sh \
    && cd /usr/bin/ \
    && chmod +rx conanexiles_controller rconcli steamcmd_setup \
    && cd /var/lib/conanexiles/ \
    && chmod +rx notifier.sh redis_cmds.sh

RUN mkdir -p /usr/share/wine/mono /usr/share/wine/gecko \
    && wget http://dl.winehq.org/wine/wine-mono/5.1.1/wine-mono-5.1.1-x86.msi -O /usr/share/wine/mono/wine-mono-5.1.1-x86.msi \
    && wget http://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86_64.msi -O /usr/share/wine/gecko/wine-gecko-2.47.2-x86_64.msi \
    && wget http://dl.winehq.org/wine/wine-gecko/2.47.2/wine-gecko-2.47.2-x86.msi -O /usr/share/wine/gecko/wine-gecko-2.47.2-x86.msi

EXPOSE 7777/udp 25575 27015/udp 27016/udp 37015/udp 37016/udp 5900

VOLUME ["/conanexiles"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord -n"]
