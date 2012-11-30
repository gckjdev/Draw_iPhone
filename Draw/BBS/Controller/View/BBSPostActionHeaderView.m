//
//  BBSPostActionHeaderView.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostActionHeaderView.h"
#import "BBSManager.h"

@implementation BBSPostActionHeaderView

- (void)initViews
{
    BBSFontManager *fontManager = [BBSFontManager defaultManager];
    BBSColorManager *colorManager = [BBSColorManager defaultManager];
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    
    [BBSViewManager updateButton:self.comment
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:nil
                            font:[fontManager detailHeaderFont]
                      titleColor:[colorManager detailDefaultColor]
                           title:nil
                        forState:UIControlStateNormal];
    [BBSViewManager updateButton:self.comment
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:nil
                            font:[fontManager detailHeaderFont]
                      titleColor:[colorManager detailHeaderSelectedColor]
                           title:nil
                        forState:UIControlStateSelected];

    [BBSViewManager updateButton:self.support
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:nil
                            font:[fontManager detailHeaderFont]
                      titleColor:[colorManager detailDefaultColor]
                           title:nil
                        forState:UIControlStateNormal];
    [BBSViewManager updateButton:self.support
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:nil
                            font:[fontManager detailHeaderFont]
                      titleColor:[colorManager detailHeaderSelectedColor]
                           title:nil
                        forState:UIControlStateSelected];

    [self.selectedLine setImage:[imageManager bbsDetailSelectedLine]];
    [self.splitLine setImage:[imageManager bbsDetailSplitLine]];

}

+ (BBSPostActionHeaderView *)createView:(id<BBSPostActionHeaderViewDelegate>)delegate
{
    NSString *identifier = [BBSPostActionHeaderView getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSPostActionHeaderView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view initViews];
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
    [self.comment setTitle:[NSString stringWithFormat:@"k评论(%d)",post.replyCount]
                  forState:UIControlStateNormal];
    [self.support setTitle:[NSString stringWithFormat:@"k顶(%d)",post.supportCount]
                  forState:UIControlStateNormal];
    
    [self.comment setTitle:[NSString stringWithFormat:@"k评论(%d)",post.replyCount]
                  forState:UIControlStateSelected];
    [self.support setTitle:[NSString stringWithFormat:@"k顶(%d)",post.supportCount]
                  forState:UIControlStateSelected];

    
    if (_selectedButton == nil) {
        _selectedButton = self.comment;
        [_selectedButton setSelected:YES];
    }
}

- (void)dealloc {
    PPRelease(_support);
    PPRelease(_comment);
    PPRelease(_selectedLine);
    PPRelease(_splitLine);
    [super dealloc];
}


- (void)moveSelectedLineBelowButton:(UIButton *)button
{
    CGFloat x = button.center.x;
    CGFloat y = self.selectedLine.center.y;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.selectedLine.center = CGPointMake(x, y);
    [UIView commitAnimations];
}

- (void)updateSelectedButton:(UIButton *)button
{
    [_selectedButton setSelected:NO];
    [button setSelected:YES];
    _selectedButton = button;
}

- (IBAction)clickSupport:(id)sender {
    [self moveSelectedLineBelowButton:sender];
    [self updateSelectedButton:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSupportTabButton)]) {
        [self.delegate didClickSupportTabButton];
    }
}

- (IBAction)clickComment:(id)sender {
    [self moveSelectedLineBelowButton:sender];
    [self updateSelectedButton:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCommentTabButton)]) {
        [self.delegate didClickCommentTabButton];
    }
}
@end
