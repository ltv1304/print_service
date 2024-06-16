FROM ubuntu:22.04 as installer
ARG DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get upgrade -y && \
    apt-get --no-install-recommends install -y \
        perl-modules \
        liburi-encode-perl \
        gnupg \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /install

COPY texlive.profile .

RUN wget --no-check-certificate http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar -xzf install-tl-unx.tar.gz --strip-components=1 && \
    ./install-tl -profile texlive.profile

FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

COPY --from=installer /usr/local/texlive /usr/local/texlive

RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

RUN apt-get update && apt-get upgrade -y && \
    apt-get --no-install-recommends install -y \
        perl-modules \
        liburi-encode-perl \
        gnupg \
        wget lmodern\
        ttf-mscorefonts-installer fontconfig fonts-liberation &&\
    rm -rf /var/lib/apt/lists/*

COPY ./fonts/* /usr/share/fonts/

ENV HOME=/tmp PATH="/usr/local/texlive/bin/x86_64-linux:$PATH"

RUN tlmgr install \
        collection-latex \
        collection-luatex \
        collection-fontsrecommended fontspec polyglossia && \
    rm -rf /usr/local/texlive/texmf-var/*

WORKDIR /work
VOLUME ["/work"]