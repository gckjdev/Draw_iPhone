//
//  AskPsListController.m
//  Draw
//
//  Created by haodong on 13-6-14.
//
//

#import "AskPsListController.h"
#import "Opus.pb.h"

@interface AskPsListController ()

@end

@implementation AskPsListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[AskPsService defaultService] getTopAskPsList:self];
}

- (void)didGetTopAskPsList:(NSArray *)list result:(int)resultCode
{
    
    if (resultCode == 0) {
        for (PBOpus *pbOpus in list) {
            PPDebug(@"id:%@", pbOpus.opusId);
            PPDebug(@"type:%d", pbOpus.type);
            PPDebug(@"desc:%@", pbOpus.desc);
            PPDebug(@"image:%@", pbOpus.image);
            PPDebug(@"thumbImage:%@", pbOpus.thumbImage);
            PPDebug(@"requirement:%@", pbOpus.askPs.requirementList);
        }
    }
}

@end
