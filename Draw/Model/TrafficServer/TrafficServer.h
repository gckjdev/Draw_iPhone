//
//  TrafficServer.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrafficServer : NSObject

@property (nonatomic, retain) NSString* serverAddress;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int language;
@property (nonatomic, assign) int usage;
@property (nonatomic, assign) int capcity;

- (id)initWithServerAddress:(NSString*)address
                       port:(int)port
                   language:(int)language
                      usage:(int)usage
                   capacity:(int)capacity;

- (NSString*)key;
+ (NSString*)keyWithServerAddress:(NSString*)address port:(int)port;

@end
