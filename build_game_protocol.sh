#!/bin/bash

SRC_DIR=`pwd`/Draw/GameServer/ProtocolBuffer
OBJC_DIR=$SRC_DIR/Gen
C_DIR=$SRC_DIR/Gen-c

CFILES=(GameBasic Draw)



cd $SRC_DIR
Files=`ls *.proto`

echo "Start to build proto files for object c"

for file in $Files
    do 
        echo "Build file: $file"
        protoc -I=$SRC_DIR --objc_out=$OBJC_DIR $SRC_DIR/$file
    done

echo "Done"

for file in ${CFILES[@]}
    do 
        echo "Build file: $file"
        filePath=$SRC_DIR/$file".proto"
        protoc-c -I=$SRC_DIR --c_out=$C_DIR $filePath
        sed "s/^.*include.*\>$/#include \"protobuf-c.h\"/" $C_DIR/$file".pb-c.h" > ~/ttt.h
        mv ~/ttt.h $C_DIR/$file".pb-c.h"
        
    done

echo "Done"
