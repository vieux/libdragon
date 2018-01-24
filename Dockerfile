ARG JOBS=8
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -yq wget bzip2 gcc g++ make file libmpfr-dev libmpc-dev libpng-dev zlib1g-dev texinfo

ENV N64_INST=/usr/local

# Compile binutils
ARG BINUTILS_V=2.27
RUN wget -c ftp://sourceware.org/pub/binutils/releases/binutils-$BINUTILS_V.tar.bz2
RUN test -d binutils-$BINUTILS_V || tar -xvjf binutils-$BINUTILS_V.tar.bz2
RUN cd binutils-$BINUTILS_V && \
    ./configure --prefix=$N64_INST --target=mips64-elf --with-cpu=mips64vr4300 --disable-werror && \
        make --jobs $JOBS && make install

# Compile gcc (pass 1)
ARG GCC_V=6.2.0
RUN wget -c ftp://sourceware.org/pub/gcc/releases/gcc-$GCC_V/gcc-$GCC_V.tar.bz2
RUN test -d gcc-$GCC_V || tar -xvjf gcc-$GCC_V.tar.bz2
RUN mkdir gcc_compile && cd gcc_compile && \
    ../gcc-$GCC_V/configure --prefix=$N64_INST --target=mips64-elf --enable-languages=c --without-headers --with-newlib --disable-libssp --enable-multilib --disable-shared --with-gcc --with-gnu-ld --with-gnu-as --disable-threads --disable-win32-registry --disable-nls --disable-debug --disable-libmudflap --disable-werror --with-system-zlib && \
        make --jobs $JOBS && make install && \
	    cd .. && rm -rf gcc_compile

# Compile newlib
ARG NEWLIB_V=2.4.0
RUN wget -c ftp://sourceware.org/pub/newlib/newlib-$NEWLIB_V.tar.gz
RUN test -d newlib-$NEWLIB_V || tar -xvzf newlib-$NEWLIB_V.tar.gz
RUN cd newlib-$NEWLIB_V && \
    CFLAGS="-O2" CXXFLAGS="-O2" ./configure --target=mips64-elf --prefix=$N64_INST --with-cpu=mips64vr4300 --disable-threads --disable-libssp  --disable-werror && \
         make --jobs $JOBS && make install

# Compile gcc (pass 2)
RUN mkdir gcc_compile && cd gcc_compile &&	\
    CFLAGS_FOR_TARGET="-G0 -O2" CXXFLAGS_FOR_TARGET="-G0 -O2" ../gcc-$GCC_V/configure --prefix=$N64_INST --target=mips64-elf --enable-languages=c,c++ --with-newlib --disable-libssp --enable-multilib --disable-shared --with-gcc --with-gnu-ld --with-gnu-as --disable-threads --disable-win32-registry --disable-nls --disable-debug --disable-libmudflap --with-system-zlib && \
        make --jobs $JOBS && make install && \
	    cd .. && rm	-rf gcc_compile

COPY . /libdragon
WORKDIR /libdragon

RUN make --jobs $JOBS && make install
RUN make --jobs $JOBS tools && make tools-install