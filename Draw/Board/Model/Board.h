//
//  Board.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{    
    BoardTypeDefault = 1,
    BoardTypeWeb = 2,
    BoardTypeImage = 3,
//    BoardTypeImage = 4    
}BoardType;

typedef enum{    
    
    BoardStatusRun = 1,//进行中
    BoardStatusStop = 2,
    
}BoardStatus;

typedef enum{    
    
    WebTypeLocal = 1,//进行中
    WebTypeRemote = 2,
    
}WebType;

@interface Board : NSObject<NSCoding>
{
    NSInteger _index;//the index on the board.
    BoardType _type;
    BoardStatus _status; //stop or running
    NSString *_version; //if the version is new? or load the local data.
    NSString *_boardId; //the boardId
}

@property(nonatomic, assign)BoardType type;
@property(nonatomic, assign)BoardStatus status;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, retain)NSString *version;
@property(nonatomic, retain)NSString *boardId; 


+(Board *)createBoardWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isRunning;
+ (Board *)defaultBoard;
@end


@interface WebBoard : Board {
    WebType _webType;
    NSString * _localUrl;
    NSString *_remoteUrl;
}

@property(nonatomic, assign)WebType webType;
@property(nonatomic, retain)NSString *localUrl;
@property(nonatomic, retain)NSString *remoteUrl;
- (NSString *)boardLocalHtmlDir;
- (NSString *)saveKey;
- (void)saveLocalURL:(NSURL *)URL;
- (NSURL *)localURL;
- (NSURL *)remoteURL;
@end

@interface ImageBoard : Board {
    NSString * _imageUrl;
    NSString * _adImageUrl;
    NSString *_clickUrl;
    NSInteger _platform;
    NSString *_publishId;

}
@property(nonatomic, retain)NSString *imageUrl;
@property(nonatomic, retain)NSString *adImageUrl;
@property(nonatomic, retain)NSString *clickUrl;
@property(nonatomic, assign)NSInteger platform;
@property(nonatomic, retain)NSString *publishId;


@end



