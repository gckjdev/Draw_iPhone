cd /java/ProtocolBuffers-2.1.0-Source/src

echo build Objective-C codes

./protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

./protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

./protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

./protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

./protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/LieDice.proto

echo build Java server codes 

cd

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Common_Java_Game/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Common_Java_Game/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Common_Java_Game/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Common_Java_Game/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/LieDice.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Common_Java_Game/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto


echo build Java Android code

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Draw_Android/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Draw_Android/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Draw_Android/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Draw_Android/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/LieDice.proto

protoc --proto_path=/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/gitdata/Draw_Android/src/ /gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto




