//
//  GameTask.h
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@class AppTask;

@interface GameTask : NSObject

@property (nonatomic, retain) PBTask_Builder *taskBuilder;

@property (nonatomic, readonly) int taskId;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* desc;
@property (nonatomic, readonly) int badge;
@property (nonatomic, readonly) int award;
@property (nonatomic, readonly) PBTaskStatus status;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) AppTask *appTask;

- (id)initWithId:(int)taskId
            name:(NSString*)name
            desc:(NSString*)desc
          status:(PBTaskStatus)status
           badge:(int)badge
           award:(int)award
        selector:(SEL)selector;

- (id)initWithId:(int)taskId
            name:(NSString*)name
            desc:(NSString*)desc
          status:(PBTaskStatus)status
           badge:(int)badge
           award:(int)award
        selector:(SEL)selector
         appTask:(AppTask*)appTask;

- (NSData*)data;
+ (GameTask*)taskFromData:(NSData*)data;

- (void)setStatus:(PBTaskStatus)status;
- (void)setBadge:(int)badge;
- (BOOL)isComplete;

@end
