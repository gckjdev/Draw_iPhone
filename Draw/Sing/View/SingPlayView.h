//
//  SingPlayView.h
//  Draw
//
//  Created by 王 小涛 on 13-10-26.
//
//

#import <UIKit/UIKit.h>
#import "DrawFeed.h"

@interface SingPlayView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

+ (id)createWithOpus:(DrawFeed *)feed;
- (void)showInView:(UIView *)view;

@end
