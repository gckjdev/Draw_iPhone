//
//  ShareActionView.m
//  Draw
//
//  Created by 王 小涛 on 13-7-4.
//
//

#import "ShareActionView.h"
#import "CommonImageManager.h"


@interface ShareActionView(){
    CustomActionSheet* _customActionSheet;
}

@property (retain, nonatomic) NSArray *actions;
@property (assign, nonatomic) id<ShareActionViewDelegate> delegate;

@end

@implementation ShareActionView

- (void)dealloc{
    [_actions release];
    [_customActionSheet release];
    [super dealloc];
}

- (id)initWithActions:(NSArray *)actions
             delegate:(id<ShareActionViewDelegate>)delegete{
    
    if (self = [super init]) {
        
        self.actions = actions;
        self.delegate = delegete;
        
        _customActionSheet = [[CustomActionSheet alloc] initWithTitle:NSLS(@"kShareTo")
                                                             delegate:self
                                                         buttonTitles:nil];
        for (NSNumber *action in actions) {
            [_customActionSheet addButtonWithTitle:[OpusActionManager nameWithAction:action.intValue]
                                             image:[OpusActionManager imageWithAction:action.intValue]];
        }
    }
    
    return self;
}

- (void)displayInView:(UIView *)inView
               atView:(UIView*)atView;
{
    if (!_customActionSheet.isVisable) {
        [_customActionSheet showInView:inView onView:atView];
    } else {
        [_customActionSheet hideActionSheet];
    }
}

- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSNumber *action = [_actions objectAtIndex:buttonIndex];
    if ([_delegate respondsToSelector:@selector(shareActionView:didSelectAction:)]) {
        [_delegate shareActionView:self didSelectAction:action.intValue];
    }
}

@end
