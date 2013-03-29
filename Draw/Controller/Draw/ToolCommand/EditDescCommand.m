//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"
#import "InputAlertView.h"

@interface EditDescCommand ()

@property(nonatomic, retain) InputAlertView *inputAlertView;

@end


@implementation EditDescCommand

- (void)dealloc
{
    [super dealloc];
}

- (UIView *)showInView
{
    UIViewController *vc = [self.control theViewController];
    return vc.view;
}

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        _inputAlertView = [InputAlertView inputAlertViewWith:NSLS(@"kEditDesc") content:nil target:self commitSeletor:NULL cancelSeletor:NULL];
    }
    return self;
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_EDIT_DESC);
}

- (void)showPopTipView
{
    self.showing = YES;

    //TODO alert the input alert view
}
- (void)hidePopTipView
{
    self.showing = NO;
    //TODO hide the alert View
}

//TODO when close the alertView, call changeDesc method
- (void)changeDesc:(NSString *)desc
{
    [self.toolHandler changeDesc:desc];
    [self hidePopTipView];
}


@end
