FROM vieux/libdragon:conker64

RUN apt-get update
RUN apt-get install -yq git
 
ENV N64_INST=/usr/local
 
COPY . /examples
WORKDIR /examples
 
RUN cd fire && make --jobs 8
RUN cd tlut && make --jobs 8 