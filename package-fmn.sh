#!/bin/sh -e

version=`echo FMN_VERSION | cpp -C -include version.h -P | grep '\.'`
fmnv="Forget-Me-Not-$version"
tmpdir="$CONFIGURATION_TEMP_DIR/$fmnv"
export PATH=$PATH:/usr/local/bin:/sw/bin:/opt/local/bin

if [ "$CONFIGURATION" != "Release" ]; then
    echo "Must use \"Release\" configuration for this target!"
    exit 1
fi

case $ACTION in
    build)
        rm -rf "$tmpdir" "$TARGET_BUILD_DIR/$fmnv.tgz"
        mkdir "$tmpdir"
        ln -fs "$TARGET_BUILD_DIR/Forget-Me-Not.prefpane" "$tmpdir"
        ln -fs "$SRCROOT/README.txt" "$SRCROOT/LICENSE.txt" "$tmpdir"
        cd "$tmpdir/.."
        tar chvzf "$TARGET_BUILD_DIR/$fmnv.tgz" "$fmnv"
        
        darcs --version || exit 0
        darcs dist "--repodir=$SRCROOT" "--dist-name=$fmnv-src"
        mv "$SRCROOT/$fmnv-src.tar.gz" "$TARGET_BUILD_DIR/$fmnv-src.tgz"
    ;;
    
    clean)
        rm -rf "$tmpdir" "$TARGET_BUILD_DIR/$fmnv.tgz"
    ;;
    
    *)
        echo "Unknown action: $ACTION"
        exit 1
    ;;
esac

