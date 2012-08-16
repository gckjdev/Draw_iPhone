//
//  Announce.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    
    AnnounceTypeAd = 1,
    AnnounceTypeLocal = 2,
    AnnounceTypeRemote = 3
    
}AnnounceType;
@interface Announce : NSObject
{
    AnnounceType _type;
    NSString *_version;
    NSString *_url;
}

@property(nonatomic, assign)AnnounceType type;
@property(nonatomic, retain)NSString *version;
@property(nonatomic, retain)NSString *url;

- (id)initWithType:(AnnounceType)type 
           version:(NSString *)version 
               url:(NSString *)url;
- (Announce *)announceWithType:(AnnounceType)type 
                     version:(NSString *)version 
                         url:(NSString *)url;
@end
