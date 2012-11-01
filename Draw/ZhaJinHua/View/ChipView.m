//
//  ChipView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-1.
//
//

#import "ChipView.h"
#import "ZJHImageManager.h"

@interface ChipView ()

@property (readwrite, nonatomic, assign) id<ChipViewProtocol> delegate;
@property (readwrite, nonatomic, assign) int chipValue;

@end

@implementation ChipView

- (id)initWithFrame:(CGRect)frame
          chipValue:(int)chipValue
           delegate:(id<ChipViewProtocol>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chipValue = chipValue;
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.image = [[ZJHImageManager defaultManager] chipImageForChipValue:chipValue];
        
        [self addSubview:imageView];
        
        [self addTarget:self action:@selector(clickSelf:) forControlEvents:UIControlEventTouchUpInside];

        self.delegate = delegate;
    }
    return self;
}

+ (ChipView *)chipViewWithFrame:(CGRect)frame
                      chipValue:(int)chipValue
                       delegate:(id<ChipViewProtocol>)delegate;
{
    return [[[self alloc] initWithFrame:frame
                              chipValue:chipValue
                               delegate:delegate] autorelease];
}

- (void)clickSelf:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didClickChipView:)]) {
        [_delegate didClickChipView:self];
    }
}


@end
