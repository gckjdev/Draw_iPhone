//
//  GameTask.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "GameTask.h"

@implementation GameTask

- (void)dealloc
{
    PPRelease(_taskBuilder);
    _selector = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    self.taskBuilder = [PBTask builder];
    return self;
}

- (id)initWithId:(int)taskId
            name:(NSString*)name
            desc:(NSString*)desc
          status:(PBTaskStatus)status
           badge:(int)badge
        selector:(SEL)selector
{
    self = [super init];
    self.taskBuilder = [PBTask builder];

    [_taskBuilder setTaskId:taskId];
    [_taskBuilder setName:name];
    [_taskBuilder setDesc:desc];
    [_taskBuilder setStatus:status];
    [_taskBuilder setBadge:badge];
    
    self.selector = selector;
    
    return self;    
}

- (NSData*)data
{
    PBTask* pbTask = [self.taskBuilder build];
    NSData* data = [pbTask data];
    self.taskBuilder = [PBTask builderWithPrototype:pbTask];
    return data;
}

+ (GameTask*)taskFromData:(NSData*)data
{
    if (data == nil){
        return nil;
    }
    
    @try {
        GameTask* task = [[[GameTask alloc] init] autorelease];
        PBTask* pbTask = [PBTask parseFromData:data];
        task.taskBuilder = [PBTask builderWithPrototype:pbTask];
        return task;
    }
    @catch (NSException *exception) {
        PPDebug(@"<taskFromData> catch exceptionl while parsing data");
    }
    @finally {
    }
    
    return nil;
    
}


- (NSString*)taskId
{
    return _taskBuilder.taskId;
}

- (NSString*)name
{
    return _taskBuilder.name;
}

- (NSString*)desc
{
    return _taskBuilder.desc;
}

- (int)badge
{
    return _taskBuilder.badge;
}

- (void)setStatus:(PBTaskStatus)status
{
    [_taskBuilder setStatus:status];
}

- (PBTaskStatus)status
{
    return _taskBuilder.status;
}


@end
