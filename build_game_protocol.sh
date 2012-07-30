cd /Users/Linruin/ProtocolBuffers-2.1.0-Source/src

echo build Objective-C codes

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

#echo build Java codes

#cd

#protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/GameServer/src/ /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

#protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/GameServer/src/ /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

#protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/GameServer/src/ /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

