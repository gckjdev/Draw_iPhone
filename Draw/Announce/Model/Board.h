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
    BoardTypeLocal = 2,
    BoardTypeRemote = 3    
    
}BoardType;
@interface Board : NSObject
{
    BoardType _type;
    NSInteger _number;
    NSString *_url;
}

@property(nonatomic, assign)BoardType type;
@property(nonatomic, assign)NSInteger number; //used for ad type, show how many ads.
@property(nonatomic, retain)NSString *url; //used for web boad.

- (id)initWithType:(BoardType)type 
           number:(NSInteger)number 
               url:(NSString *)url;

+ (Board *)boardWithType:(BoardType)type 
                     number:(NSInteger)number 
                         url:(NSString *)url;
@end
