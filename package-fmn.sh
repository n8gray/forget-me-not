#!/bin/sh -e

version=1.0
fmnv=Forget-Me-Not-$version
tmpdir=$CONFIGURATION_TEMP_DIR/$fmnv

if [ "$CONFIGURATION" != "Release" ]; then
    echo "Must use \"Release\" configuration for this target!"
    exit 1
fi

case $ACTION in
    build)
        rm -rf $tmpdir $TARGET_BUILD_DIR/$fmnv.tgz
        mkdir $tmpdir
        ln -fs $TARGET_BUILD_DIR/Forget-Me-Not.prefpane $tmpdir
        ln -fs $SRCROOT/{README.txt,LICENSE.txt} $tmpdir
        cd $tmpdir/..
        tar chvzf $TARGET_BUILD_DIR/$fmnv.tgz $fmnv
    ;;
    
    clean)
        rm -rf $tmpdir $TARGET_BUILD_DIR/$fmnv.tgz    
    ;;
    
    *)
        echo "Unknown action: $ACTION"
        exit 1
    ;;
esac

