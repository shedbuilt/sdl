#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
SHED_PKG_LOCAL_OPENGL_OPTION='disable'
SHED_PKG_LOCAL_X11_OPTION='disable'
SHED_PKG_LOCAL_FBCON_OPTION='disable'
SHED_PKG_LOCAL_DUMMY_VIDEO_OPTION='enable'
for SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        opengl)
            SHED_PKG_LOCAL_OPENGL_OPTION='enable'
            SHED_PKG_LOCAL_DUMMY_VIDEO_OPTION='disable'
            ;;
        x11)
            SHED_PKG_LOCAL_X11_OPTION='enable'
            SHED_PKG_LOCAL_DUMMY_VIDEO_OPTION='disable'
            ;;
        fbcon)
            SHED_PKG_LOCAL_FBCON_OPTION='enable'
            SHED_PKG_LOCAL_DUMMY_VIDEO_OPTION='disable'
            ;;
    esac
done
# Patch
sed -e '/_XData32/s:register long:register _Xconst long:' \
    -i src/video/x11/SDL_x11sym.h &&
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/pssc-sdl-fbcon.patch" &&
# Configure
./configure --prefix=/usr \
            --docdir="$SHED_PKG_DOCS_INSTALL_DIR"
            --build=$SHED_NATIVE_TARGET \
            --disable-static \
            --enable-alsa \
            --disable-oss \
            --disable-esd \
            --disable-pulseaudio \
            --disable-dummyaudio \
            --disable-video-directfb \
            --disable-video-caca \
            --${SHED_PKG_LOCAL_X11_OPTION}-video-x11 \
            --${SHED_PKG_LOCAL_FBCON_OPTION}-video-fbcon \
            --${SHED_PKG_LOCAL_DUMMY_VIDEO_OPTION}-video-dummy \
            --${SHED_PKG_LOCAL_OPENGL_OPTION}-video-opengl &&
# Build and Install
make -j $SHED_NUM_JOBS &&
make DESTDIR="$SHED_FAKE_ROOT" install || exit 1
# Install Documentation
if [ -n "${SHED_PKG_LOCAL_OPTIONS[docs]}" ]; then
    install -vdm755 "${SHED_FAKE_ROOT}${SHED_PKG_DOCS_INSTALL_DIR}/html" &&
    install -vm644 docs/html/*.html "${SHED_FAKE_ROOT}${SHED_PKG_DOCS_INSTALL_DIR}/html" || exit 1
else
    rm -rf "${SHED_FAKE_ROOT}${SHED_PKG_DOCS_INSTALL_DIR}"
fi
