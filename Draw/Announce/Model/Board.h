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
    NSString *_version;
    NSString *_url;
}

@property(nonatomic, assign)BoardType type;
@property(nonatomic, retain)NSString *version;
@property(nonatomic, retain)NSString *url;

- (id)initWithType:(BoardType)type 
           version:(NSString *)version 
               url:(NSString *)url;

- (Board *)BoardWithType:(BoardType)type 
                     version:(NSString *)version 
                         url:(NSString *)url;
@end
