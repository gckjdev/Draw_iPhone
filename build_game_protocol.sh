#!/bin/bash

pwd=`pwd`
SRC_DIR=$pwd"/Draw/GameServer/ProtocolBuffer"
OBJC_DIR=$SRC_DIR/Gen
C_DIR=$SRC_DIR/Gen-c
JAVA_DIR=$pwd"/../Common_Java_Game/src/"


CFILES=(GameBasic Draw)


cd $SRC_DIR
Files=`ls *.proto`

echo "Start to build proto files for object c"

for file in $Files
    do 
        echo "Build file: $file"
        protoc_2.2 -I=$SRC_DIR --objc_out=$OBJC_DIR $SRC_DIR/$file
    done

echo "Done"

echo "Start to build proto files for Java"

for file in $Files
    do 
        echo "Build file: $file"
        protoc_2.4 -I=$SRC_DIR --java_out=$JAVA_DIR $SRC_DIR/$file
    done

echo "Done"


exit 0

for file in ${CFILES[@]}
    do 
        echo "Build file: $file"
        filePath=$SRC_DIR/$file".proto"
        protoc-c -I=$SRC_DIR --c_out=$C_DIR $filePath
        sed "s/^.*include.*\>$/#include \"protobuf-c.h\"/" $C_DIR/$file".pb-c.h" > ~/ttt.h
        mv ~/ttt.h $C_DIR/$file".pb-c.h"
        
    done
