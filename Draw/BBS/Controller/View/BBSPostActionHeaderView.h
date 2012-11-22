//
//  BBSPostActionHeaderView.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import <UIKit/UIKit.h>
#import "Bbs.pb.h"

@protocol BBSPostActionHeaderViewDelegate <NSObject>

@optional
- (void)didClickSupportTabButton;
- (void)didClickCommentTabButton;

@end

@interface BBSPostActionHeaderView : UIView

{
    
}
@property (retain, nonatomic) IBOutlet UIButton *support;
@property (retain, nonatomic) IBOutlet UIButton *comment;
@property (assign, nonatomic) id<BBSPostActionHeaderViewDelegate>delegate;

- (IBAction)clickSupport:(id)sender;
- (IBAction)clickComment:(id)sender;

+ (BBSPostActionHeaderView *)createView:(id<BBSPostActionHeaderViewDelegate>)delegate;
+ (CGFloat)getViewHeight;
+ (NSString *)getViewIdentifier;
- (void)updateViewWithPost:(PBBBSPost *)post;
@end
