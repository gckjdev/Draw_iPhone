//
//  BBSPostCommand.h
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import <Foundation/Foundation.h>
#import "BBSModelExt.h"
#import "BBSService.h"
#import "PPTableViewController.h"
#import "BBSPostDetailController.h"
#import "BBSActionSheet.h"

@protocol BBSPostCommandProtocol <NSObject>
@required
- (void)excute;
- (NSString *)name;
- (UIImage *)icon;
@end

@interface BBSPostCommand : NSObject<BBSServiceDelegate,BBSPostCommandProtocol>

@property(nonatomic, retain)PBBBSPost *post;
@property(nonatomic, assign)BBSPostDetailController *controller;

- (id)initWithPost:(PBBBSPost *)post controller:(BBSPostDetailController *)controller;

@end

@interface BBSPostSupportCommand : BBSPostCommand

@end

@interface BBSPostTransferCommand : BBSPostCommand<BBSOptionViewDelegate>

@end

@interface BBSPostReplyCommand : BBSPostCommand

@end

@interface BBSPostTopCommand : BBSPostCommand

@end

@interface BBSPostDeleteCommand : BBSPostCommand<UIAlertViewDelegate>

@end
