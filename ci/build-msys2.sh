#!/bin/bash -e

. ./ci/build-common.sh

# 强制使用静态库进行链接，使依赖库嵌入 DLL
export PKG_CONFIG="pkg-config --static"

args=(
  -D{amf,cdda,d3d-hwaccel,d3d11,dvdnav,jpeg,lcms2,libarchive}=enabled
  -D{libbluray,lua,shaderc,spirv-cross,uchardet,vapoursynth}=enabled
  -D{egl-angle-lib,egl-angle-win32,pdf-build,rubberband,win32-smtc}=enabled
)

if [[ -n "$ASAN" ]]; then
    args+=(
      -Db_sanitize=address,undefined
    )
fi

if [[ -n "$AUTO_VAR_INIT" ]]; then
    args+=(
        -Dc_args="-ftrivial-auto-var-init=$AUTO_VAR_INIT"
        -Dcpp_args="-ftrivial-auto-var-init=$AUTO_VAR_INIT"
    )
fi

echo "::group::Building subrandr"
build_subrandr "/$SYS"
echo "::endgroup::"
args+=(-Dsubrandr=enabled)

# 禁用测试以避免 -ldl 链接错误
meson setup build $common_args "${args[@]}" -Dtests=false
meson compile -C build
./build/mpv.com -v --no-config
