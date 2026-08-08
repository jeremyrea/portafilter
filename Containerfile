FROM registry.suse.com/bci/bci-base:16.0 AS base

RUN zypper dup -y && zypper install -y \
    awk \
    curl \
    gcc \
    make \
    libopenssl-devel \
    m4 \
    pkgconf \
    openssl \
    ca-certificates \
    && zypper clean --all


FROM base as build-ripmime    

ARG RIPMIME_VERSION=1.4.1.0

WORKDIR /src

RUN curl -L https://github.com/inflex/ripMIME/archive/refs/tags/${RIPMIME_VERSION}.tar.gz > ripMIME.tar.gz && \
    tar -xf ripMIME.tar.gz && \
    cd ripMIME-${RIPMIME_VERSION} && \
    make CFLAGS="-Wall -O3 -march=x86-64-v3" && \
    make install && \
    strip /usr/local/bin/ripmime \
    /lib64/libc.so.6 \
    /lib64/ld-linux-x86-64.so.2 

FROM base as build-fetchmail   

ARG FETCHMAIL_VERSION=6.6.6

WORKDIR /src

RUN curl -L https://sourceforge.net/projects/fetchmail/files/branch_6.6/fetchmail-${FETCHMAIL_VERSION}.tar.xz > fetchmail.tar.xz && \
    tar -xf fetchmail.tar.xz && \
    cd fetchmail-${FETCHMAIL_VERSION} && \
    ./configure --with-ssl --disable-nls && \
    make -j8 check && \
    make install && \
    strip /usr/local/bin/fetchmail \
    /lib64/libssl.so.3 \
    /lib64/libcrypto.so.3 \
    /lib64/libc.so.6 \
    /lib64/libjitterentropy.so.3 \
    /lib64/libz.so.1 \
    /lib64/ld-linux-x86-64.so.2 && \
    groupadd -g 1000 portafilter && \
    useradd --uid 1000 --gid 1000 --shell /sbin/nologin portafilter

FROM registry.suse.com/bci/bci-micro:16.0

ENV HOME=/tmp/portafilter

COPY --from=base /var/lib/ca-certificates/ca-bundle.pem /etc/ssl/ca-bundle.pem
COPY --from=build-ripmime /lib64/libc.so.6 /lib64/
COPY --from=build-ripmime /lib64/ld-linux-x86-64.so.2 /lib64/
COPY --from=build-ripmime /usr/local/bin/ripmime /usr/local/bin/ripmime
COPY --from=build-fetchmail /lib64/libssl.so.3 /lib64/
COPY --from=build-fetchmail /lib64/libcrypto.so.3 /lib64/
COPY --from=build-fetchmail /lib64/libjitterentropy.so.3 /lib64/
COPY --from=build-fetchmail /lib64/libz.so.1 /lib64/
COPY --from=build-fetchmail /usr/local/bin/fetchmail /usr/local/bin/fetchmail
COPY --from=build-fetchmail /etc/passwd /etc/passwd
COPY --from=build-fetchmail /etc/group /etc/group
COPY run.sh /usr/local/bin/run.sh

RUN chmod 755 /usr/local/bin/ripmime /usr/local/bin/run.sh

USER portafilter

ENTRYPOINT ["/usr/local/bin/run.sh"]