//
//  OpusImageBrower.m
//  Draw
//
//  Created by 王 小涛 on 13-7-12.
//
//

#import "OpusImageBrower.h"
#import "UIImageView+Extend.h"
#import "AutoCreateViewByXib.h"

@implementation OpusImageBrower

AUTO_CREATE_VIEW_BY_XIB(OpusImageBrower);

- (void)dealloc {
    [_opusImageView release];
    [super dealloc];
}


+ (id)createWithThumbImageUrl:(NSString *)thumbImageUrl
                     imageUrl:(NSString *)imageUrl{
    
    OpusImageBrower *brower = [self createView];
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURL *thumbUrl = [NSURL URLWithString:thumbImageUrl];
    [brower.opusImageView setImageWithUrl:url thumbImageUrl:thumbUrl placeholderImage:nil];
    
    return brower;
}

- (void)showInView:(UIView *)view{
    
    self.frame = view.bounds;
    [view addSubview:self];
}


- (IBAction)clickBgButton:(id)sender {
    
    [self removeFromSuperview];
}

@end
