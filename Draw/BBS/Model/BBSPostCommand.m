//
//  BBSPostCommand.m
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import "BBSPostCommand.h"



@implementation BBSPostCommand
- (id)initWithPost:(PBBBSPost *)post controller:(BBSPostDetailController *)controller
{
    self = [super init];
    if (self) {
        self.post = post;
        self.controller = controller;
    }
    return self;
}
- (void)excute
{
    PPDebug(@"<BBSPostCommand>excute, no action");
}
- (NSString *)name
{
    PPDebug(@"<BBSPostCommand>name, no name");
    return nil;
}
- (UIImage *)icon
{
    PPDebug(@"<BBSPostCommand>icon, no icon");
    return nil;
}

- (void)dealloc
{
    PPRelease(_post);
    [super dealloc];
}

@end

@implementation BBSPostSupportCommand
-(void)excute{
    [[BBSService defaultService] createActionWithPostId:self.post.postId
                                                PostUid:self.post.postUid
                                               postText:self.post.postText
                                           sourceAction:nil
                                             actionType:ActionTypeSupport
                                                   text:nil
                                                  image:nil
                                         drawActionList:nil
                                              drawImage:nil
                                               delegate:self.controller];

}

- (NSString *)name{
    return NSLS(@"kBBSSupport");
}
- (void)dealloc
{
    [super dealloc];
}

@end

@implementation BBSPostReplyCommand
-(void)excute{
    [CreatePostController enterControllerWithSourecePost:self.post
                                            sourceAction:nil
                                          fromController:self.controller].delegate = self.controller;
    
}
- (NSString *)name{
    return NSLS(@"kBBSReply");
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation BBSPostTransferCommand

-(void)excute{
    
}
- (NSString *)name{
    return NSLS(@"kBBSTransfer");
}

- (void)dealloc
{
    [super dealloc];
}


@end



@implementation BBSPostTopCommand

-(void)excute{
    
}

- (NSString *)name{
    return NSLS(@"kBBSToTop");
}

- (void)dealloc
{
    [super dealloc];
}


@end

@implementation BBSPostDeleteCommand

-(void)excute{
    
}
- (NSString *)name{
    return NSLS(@"kBBSDelete");
}

- (void)dealloc
{
    [super dealloc];
}

@end