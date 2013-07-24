#!/bin/bash


pwd=`pwd`
SRC_DIR=$pwd"/Draw/GameServer/ProtocolBuffer"
OBJC_DIR=$SRC_DIR/Gen
C_DIR=$SRC_DIR/Gen-c
JAVA_DIR=$pwd"/../Common_Java_Game/src/"

BUILD_C=true
if [ z$1 = zc ]
    then BUILD_C=true
    else BUILD_C=false
fi

CFILES=(GameBasic Draw)


cd $SRC_DIR
Files=`ls *.proto`

loc=`which protoc_2.2`
if [ z$loc = z ]
then
echo "Cannot find protoc_2.2, Fails to build protobuf for OBJC"
exit 1
fi


echo "Start to build proto files for object c"

for file in $Files
    do 
        echo "Build file: $file"
        "protoc_2.2" -I=$SRC_DIR --objc_out=$OBJC_DIR $SRC_DIR/$file
    done

echo "Done"

if $BUILD_C
then
echo "Start to build proto files for C"
for file in ${CFILES[@]}
    do 
        echo "Build file: $file"
        filePath=$SRC_DIR/$file".proto"
        protoc-c -I=$SRC_DIR --c_out=$C_DIR $filePath
        sed "s/^.*include.*\>$/#include \"protobuf-c.h\"/" $C_DIR/$file".pb-c.h" > ~/ttt.h
        mv ~/ttt.h $C_DIR/$file".pb-c.h"
        
    done
fi


loc=`which protoc_2.4`
if [ z$loc = z ]
then
echo "Cannot find protoc_2.4, Fails to build protobuf for Java"
exit 1
fi

echo "Start to build proto files for Java"

for file in $Files
    do 
        echo "Build file: $file"
        protoc_2.4 -I=$SRC_DIR --java_out=$JAVA_DIR $SRC_DIR/$file
    done

echo "Done"

