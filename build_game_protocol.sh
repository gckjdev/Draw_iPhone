cd /Users/Linruin/ProtocolBuffers-2.2.0-Source/src

echo build Objective-C codes

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ZhaJinHua.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Sing.proto

./protoc --proto_path=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/Linruin/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Opus.proto

