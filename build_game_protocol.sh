#!/bin/bash

PROTOC=$(which protoc)


#echo "building Objective-C codes..."

#$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

#$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

#$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto


echo "building Java codes..."

$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/home/larmbr/gckj/Common_Java_Game/src/ /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/home/larmbr/gckj/Common_Java_Game/src/ /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

$PROTOC --proto_path=/home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/home/larmbr/gckj/Common_Java_Game/src/ /home/larmbr/gckj/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

