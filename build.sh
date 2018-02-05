#!/bin/bash
sed -e '/_XData32/s:register long:register _Xconst long:' \
    -i src/video/x11/SDL_x11sym.h
./configure --prefix=/usr \
            --disable-static \
            --enable-video-fbcon \
            --enable-alsa \
            --disable-oss \
            --disable-esd \
            --disable-pulseaudio \
            --disable-dummyaudio \
            --disable-video-x11 \
            --disable-video-directfb \
            --disable-video-caca \
            --disable-video-dummy \
            --disable-video-opengl && \
make -j $SHED_NUMJOBS && \
make DESTDIR="$SHED_FAKEROOT" install || exit 1
install -v -d -m755 "${SHED_FAKEROOT}/usr/share/doc/SDL-1.2.15/html"
install -v -m644 docs/html/*.html "${SHED_FAKEROOT}/usr/share/doc/SDL-1.2.15/html"