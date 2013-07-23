//
//  CommonBgView.m
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import "CommonBgView.h"

#define FRAME (ISIPAD ? CGRectMake(0, 0, 768, 1004) : CGRectMake(0, 0, 320, 460))

@interface CommonBgView()

@property (retain, nonatomic) UIImageView *imageView;
@end

@implementation CommonBgView

- (void)dealloc{
    
    [_imageView release];
    [super dealloc];
}

+ (CommonBgView *)create{
    CommonBgView *bgView = [[[self alloc] init] autorelease];
    [bgView update];
    return bgView;
}

- (id)init{
    
    if (self = [super initWithFrame:FRAME]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)update{
    
    _imageView.backgroundColor = [UIColor colorWithRed:234/255.0     green:231/255.0 blue:225/255.0 alpha:1];
}


@end
