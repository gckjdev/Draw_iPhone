//
//  BBSPostActionHeaderView.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostActionHeaderView.h"

@implementation BBSPostActionHeaderView

+ (BBSPostActionHeaderView *)createView:(id<BBSPostActionHeaderViewDelegate>)delegate
{
    NSString *identifier = [BBSPostActionHeaderView getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSPostActionHeaderView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return  view;
}

+ (NSString *)getViewIdentifier
{
    return @"BBSPostActionHeaderView";
}
+ (CGFloat)getViewHeight
{
    return 40;
}
- (void)updateViewWithPost:(PBBBSPost *)post
{
    [self.support setTitle:[NSString stringWithFormat:@"SP(%d)",post.supportCount]
                  forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@"CM(%d)",post.replyCount]
                  forState:UIControlStateNormal];
}

- (void)dealloc {
    [_support release];
    [_comment release];
    [super dealloc];
}
- (IBAction)clickSupport:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSupportTabButton)]) {
        [self.delegate didClickSupportTabButton];
    }
}

- (IBAction)clickComment:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCommentTabButton)]) {
        [self.delegate didClickCommentTabButton];
    }
}
@end
