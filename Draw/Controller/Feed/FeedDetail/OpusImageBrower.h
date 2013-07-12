//
//  OpusImageBrower.h
//  Draw
//
//  Created by 王 小涛 on 13-7-12.
//
//

#import <UIKit/UIKit.h>

@interface OpusImageBrower : UIView

@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;

+ (id)createWithThumbImageUrl:(NSString *)thumbImageUrl
                     imageUrl:(NSString *)imageUrl;
- (void)showInView:(UIView *)view;

@end
