//
//  Board.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{    
    
    BoardTypeAd = 1,
    BoardTypeWeb = 2,
    BoardTypeImage = 3    
    
}BoardType;

typedef enum{    
    
    BoardStatusRun = 1,//进行中
    BoardStatusStop = 2,
    
}BoardStatus;


@interface Board : NSObject
{
    NSInteger _index;//the index on the board.
    BoardType _type;
    BoardStatus _status; //stop or running
    NSString *_version; //if the version is new? or load the local data.
}

@property(nonatomic, assign)BoardType type;
@property(nonatomic, assign)BoardStatus status;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, retain)NSString *version; 

- (id)initWithType:(BoardType)type 
            status:(BoardStatus)status  
             index:(NSInteger)index
            version:(NSString *)version;

@end
