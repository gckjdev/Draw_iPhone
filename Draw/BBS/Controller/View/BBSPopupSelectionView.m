//
//  BBSPopupSelectionView.m
//  Draw
//
//  Created by gamy on 12-11-30.
//
//

#import "BBSPopupSelectionView.h"

#define ISIPAD [DeviceDetection isIPAD]

#define SPACE_TOP_BUTTON (ISIPAD ? 7*2 : 7)
#define SPACE_BOTTOM_BUTTON (ISIPAD ? 15*2 : 15)
#define SPACE_LEFTRIGHT_BUTTON (ISIPAD ? 8*2 : 8)
#define SPACE_BUTTON_BUTTON (ISIPAD ? 7*2 : 7)

#define SPACE_LEFTRIGHT_TIP (ISIPAD ? 30*2 : 30)

#define BUTTON_SIZE (ISIPAD ? CGSizeMake(82,43) : CGSizeMake(41,22))

@interface BBSPopupSelectionView ()
{
    NSArray *_titles;
}
@property(nonatomic, retain)NSArray *titles;
@property(nonatomic, assign)id<BBSPopupSelectionViewDelegate>delegate;

@end

@implementation BBSPopupSelectionView

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSPopupSelectionViewDelegate>)delegate;
{
    self = [super init];
    if (self) {
        self.titles = titles;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_titles);
    [super dealloc];
}


- (void)updateFrameWithSuperView:(UIView *)view showAbovePoint:(CGPoint )point
{
    NSInteger count = [_titles count];
    CGFloat width = count * BUTTON_SIZE.width + (count - 1) *SPACE_BUTTON_BUTTON;
    width += (SPACE_LEFTRIGHT_BUTTON * 2);
    CGFloat height = BUTTON_SIZE.height + SPACE_TOP_BUTTON + SPACE_BOTTOM_BUTTON;
    CGFloat y = height + point.y;
    CGFloat x = 0;
    //if tip at left
    if (point.x < view.center.x) {
        x = point.x - SPACE_LEFTRIGHT_TIP;
    }else{
        x = point.x + SPACE_LEFTRIGHT_TIP - width;
    }
    self.frame = CGRectMake(x, y, width, height);
}
- (void)updateButtons
{
    NSInteger i = 0;
}

- (void)showInView:(UIView *)view showAbovePoint:(CGPoint )point
{
    [view addSubview:self];
    [self updateFrameWithSuperView:view
                    showAbovePoint:point];
    [self updateButtons];
//    [sel]
}


@end
