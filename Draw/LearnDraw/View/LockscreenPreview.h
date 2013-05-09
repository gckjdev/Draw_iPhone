//
//  LockscreenPreview.h
//  Draw
//
//  Created by haodong on 13-5-8.
//
//

#import <UIKit/UIKit.h>

@interface LockscreenPreview : UIView

@property (retain, nonatomic) IBOutlet UIImageView *contentImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *slideLabel;

+ (LockscreenPreview *)createWithImage:(UIImage *)image;

- (void)showInView:(UIView *)superView;

@end
