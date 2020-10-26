FROM debian:jessie

# Add repo and install Freeswitch 1.8
RUN apt-get update \
    && apt-get install -y wget gnupg2 \
    && wget -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update && apt-get install -y freeswitch-meta-vanilla \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove \
    && apt-get clean

# Enabling codecs and modules
ARG CODECS=OPUS,G722,PCMU,PCMA,VP8,H264,H263,H263-1998
RUN sed -i 's/^.*global_codec_prefs.*$/<X-PRE-PROCESS cmd="set" data="global_codec_prefs='$CODECS'"\/>/g' /etc/freeswitch/vars.xml \ 
    && sed -i 's/^.*outbound_codec_prefs.*$/<X-PRE-PROCESS cmd="set\" data="outbound_codec_prefs='$CODECS'"\/>/g' /etc/freeswitch/vars.xml \
    && sed -i 's/^.*inbound-codec-prefs.*$/<param name="inbound-codec-prefs" value="'$CODECS'"\/>/g' /etc/freeswitch/sip_profiles/internal.xml

ARG MODULE=mod_av
RUN sed -i 's/^.*'$MODULE'.*$/<load module="'$MODULE'"\/>/g' /etc/freeswitch/autoload_configs/modules.conf.xml

# Disable the example gateway and the IPv6 SIP profiles
RUN set -ex; \
    cd /etc/freeswitch; \
    mv directory/default/example.com.xml directory/default/example.com.xml.noload; \
    mv sip_profiles/external-ipv6.xml sip_profiles/external-ipv6.xml.noload; \
    mv sip_profiles/internal-ipv6.xml sip_profiles/internal-ipv6.xml.noload

## Ports
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 8021/tcp \
    5060/tcp 5060/udp 5080/tcp 5080/udp \
    5061/tcp 5061/udp 5081/tcp 5081/udp \
    7443/tcp \
    5070/udp 5070/tcp \
    64535-65535/udp \
    16384-32768/udp

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -x status | grep -q ^UP || exit 1

# Running command
CMD ["freeswitch", "-u", "freeswitch", "-g", "freeswitch", "-nonat", "-nf", "-nc"]

# Description
LABEL \
	project="docker/freeswitch" \
	version="1.0.0" \
	maintainer="Sergey Kurbatov - kurbatov.sergs@gmail.com" \
	build-date=$BUILD_DATE
