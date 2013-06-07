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
}

@end

@implementation HomeBottomMenuPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    NSString* identifier = [HomeBottomMenuPanel getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    HomeCommonView<HomeCommonViewProtocol> *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
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
            CGRect frame = view.frame;
            frame.origin = CGPointMake(x, frame.origin.y);
            frame.size = CGSizeMake(width, frame.size.height);
            view.frame = frame;
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
        if (isDrawApp() && !isLittleGeeAPP()) {
            line.image = imageManager.drawHomeSplitline1;
        }else if(isLearnDrawApp()){
            line.image = imageManager.learnDrawBottomSplit;
        }else if (isLittleGeeAPP()) {
            line.image = [imageManager littleGeeBottomSplit];
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
    return (id)[self viewWithTag:1234];
}

- (void)updateView
{
    if (isDrawApp() || isLittleGeeAPP() || isSingApp()) {
        [[self bgImageView] removeFromSuperview];
    }
    
    if (isLearnDrawApp()) {
        [[self bgImageView] setImage:[[DrawImageManager defaultManager] learnDrawBottomBar]];
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
@end
