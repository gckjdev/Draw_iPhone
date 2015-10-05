cd /java/ProtocolBuffers-2.1.0-Source/src

echo build Objective-C codes

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Tutorial.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Group.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ZhaJinHua.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/BBS.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Config.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Photo.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Sing.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --objc_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Opus.proto

echo build C codes

cd /java/protobuf-c-0.15/bin/

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Tutorial.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Group.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ZhaJinHua.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/BBS.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Config.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Photo.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Sing.proto

protoc-c --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --c_out=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Gen-c /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Opus.proto



echo build Java server codes 

cd /java/protobuf-2.4.1/bin

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Tutorial.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Group.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ZhaJinHua.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/BBS.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Config.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Photo.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Opus.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Sing.proto


echo build Java Android code

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameBasic.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameConstants.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/GameMessage.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Dice.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Draw.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Tutorial.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/DrawJava/Common_Java_Game/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Group.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ZhaJinHua.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/BBS.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Config.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Photo.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Sing.proto

protoc --proto_path=/Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/ --java_out=/Users/pipi/gitdata/Draw_Android/src/ /Users/pipi/gitdata/Draw_iPhone/Draw/GameServer/ProtocolBuffer/Opus.proto



