//
//  HomeBottomMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeBottomMenuPanel.h"
#import "DrawImageManager.h"
#import "MobClick.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define SPLIT_WIDTH (ISIPAD ? 12 : 6)


@interface HomeBottomMenuPanel()
{
    NSInteger _menuCount;
    UIImageView *_bgView;
}

@end

#define SELF_SIZE (ISIPAD?CGSizeMake(768,76):CGSizeMake(320,38))

@implementation HomeBottomMenuPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgView.autoresizingMask = (0x1<<6)-1;
        [self addSubview:_bgView];
        [_bgView release];
        [self updateView];
    }
    return self;
}

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    CGRect frame = CGRectZero;
    frame.size = SELF_SIZE;
    HomeCommonView<HomeCommonViewProtocol> *view = [[HomeBottomMenuPanel alloc] initWithFrame:frame];
    view.delegate = delegate;
    return [view autorelease];
}

+ (NSString *)getViewIdentifier
{
    return @"HomeBottomMenuPanel";
}


- (HomeMenuView *)viewWithType:(HomeMenuType)type
                         index:(NSInteger)index
{
    HomeMenuView *view = [HomeMenuView menuViewWithType:type badge:0 delegate:self];
    CGFloat viewWidth = view.frame.size.width;
    CGFloat x = viewWidth * index;
    CGFloat y = 0;
    CGRect frame = view.frame;
    frame.origin = CGPointMake(x, y);
    view.frame = frame;
    return view;
}

//- (void)updateMenuView:(HomeMenuView *)view size:(CGSize)size
//{
//    CGRect frame = view.frame;
//    frame.size = size;
//    view.frame = frame;
//}

- (void)addMenuViews
{
    int *list = getBottomMenuTypeList();

    _menuCount = 0;
    NSMutableArray *array = [NSMutableArray array];
//    PPDebug(@"TypeList = (");
    while (list != NULL && (*list) != HomeMenuTypeEnd) {
        HomeMenuType type = (*list);
//        PPDebug(@"%d,", type);
        HomeMenuView *view = [self viewWithType:type index:_menuCount++];
        
        //TODO update view width
        
        if (view) {
            [self addSubview:view];
            [array addObject:view];
        }
        list++;
    }
//    PPDebug(@");");
    if (_menuCount > 0) {
        CGFloat width = WIDTH / _menuCount;
        CGFloat x = 0;
        for (HomeMenuView *view in array) {
            [view updateOriginX:x];
            [view updateWidth:width];
            [view updateCenterY:CGRectGetMidY(self.bounds)];
            x += width;
        }
    }
}

- (void)addSplitLines
{
    if (_menuCount <= 1) {
        return;
    }
    NSInteger count = _menuCount - 1;
    DrawImageManager *imageManager = [DrawImageManager defaultManager];
    CGFloat space = WIDTH / _menuCount;
    for (NSInteger i = 0; i < count; ++ i) {

        CGRect frame = CGRectMake(0, 0, SPLIT_WIDTH, HEIGHT*0.5);
        PPDebug(@"#%d: frame = %@",i, NSStringFromCGRect(frame));
        UIImageView *line = [[UIImageView alloc] initWithFrame:frame];

        
        CGFloat x = space * (i+1);
        CGFloat y = self.center.y;
        line.center = CGPointMake(x, y);
        if (isDrawApp()) {
            line.image = imageManager.drawHomeSplitline1;
        }else if (isSingApp()) {
            line.image = [imageManager drawHomeSplitline1];
        }
        else{
            line.image = imageManager.drawHomeSplitline;
        }
        [self addSubview:line];
        [line release];
    }
}

- (UIImageView *)bgImageView
{
    return _bgView;;
}

- (void)updateView
{
    
    if (isSingApp()) {
        [[self bgImageView] setImage:[[DrawImageManager defaultManager] singBottomBar]];
    }else{
        [[self bgImageView] setImage:[[DrawImageManager defaultManager] drawHomeBottomBarImage]];
    }
    
    //add menu views;
    [self addMenuViews];
    //add split lines
    [self addSplitLines];
}

- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type
{
    for (HomeMenuView *view in self.subviews) {
        if ([view isKindOfClass:[HomeMenuView class]] && view.type == type) {
            return view;
        }
    }
    return nil;
}

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge
{
    HomeMenuView *view = [self getMenuViewWithType:type];
    [view updateBadge:badge];
}


#pragma mark - Home Menu View Delegate
- (void)didClickMenu:(HomeMenuView *)menu type:(HomeMenuType)type
{
    [MobClick event:@"CLICK_MENU_BUTTON"
              label:[HomeMenuView titleForType:type]
                acc:1];

    if (self.delegate && [self.delegate respondsToSelector:@selector(homeBottomMenuPanel:didClickMenu:menuType:)]) {
        [self.delegate homeBottomMenuPanel:self didClickMenu:menu menuType:type];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - 20;
    if (animated) {
        [UIView animateWithDuration:BOTTOM_ANIMATION_INTERVAL animations:^{
            [self updateOriginY:y];            
        }];
    }else{
        [self updateOriginY:y];
    }
}
- (void)showAnimated:(BOOL)animated
{
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetHeight(self.bounds) - 20;
    if (animated) {
        [UIView animateWithDuration:BOTTOM_ANIMATION_INTERVAL animations:^{
            [self updateOriginY:y];
        }];
    }else{
        [self updateOriginY:y];
    }    
}

@end
