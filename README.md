# freeswitch-docker

Dockerfile for running FreeSWITCH in a Docker container.

    Base image: debian:jessie
    Exposed ports:
        - 5060 TCP/UDP
        - 1813 TCP/UDP
        - 5080 TCP/UDP
        - 5061 TCP/UDP
        - 5081 TCP/UDP
        - 7443 TCP
        - 64535-65535 UDP
        - 16384-32768 UDP
    Volumes: None


# Docker-compose
To quickly launch through Docker-compose, run the following command:
    `docker-compose up -d`

# Docker

For docker image build: 
    
    docker build -t freeswitch .
    
For docker container run: 

    docker run -d --name=freeswitch -p 5060:5060 -p 1813:1813 \
    -p 5080:5080 -p 5061:5061 -p 5081:5081 -p 7443:7443 -p 5070:5070 \
    -p 64535-65535:64535-65535 \
    freeswitch

# Configuration
For the most part used the default "vanilla" configuration that FreeSWITCH installs in /usr/share/freeswitch/conf/vanilla. However, we do override some of the configuration options. The changes are as follows:

    autoload_configs/console.conf.xml:
        Disable console colorizing as this seems to break some logging systems.
    autoload_configs/event_socket.conf.xml:
        Bind to 0.0.0.0 instead of :: to disable IPv6 (which has issues as described above).
    directory/default/example.com.xml:
        This file is renamed to prevent FreeSWITCH from setting up an example (and non-functional) SIP gateway.
    sip_profiles/{external,internal}-ipv6.xml:
        These files are renamed to disable IPv6 SIP profiles.