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


+ (LockscreenPreview *)createWithImage:(UIImage *)image;

- (void)showInView:(UIView *)superView;

@end
