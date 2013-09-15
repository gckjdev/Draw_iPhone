//
//  DrawMainMenuPanel.m
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "DrawMainMenuPanel.h"
#import "HomeMenuView.h"
#import "AnimationManager.h"


@interface DrawMainMenuPanel()
@property(nonatomic, retain)NSMutableArray *menuList;
@end

@implementation DrawMainMenuPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    DrawMainMenuPanel *panel = [self createViewWithXibIdentifier:[self getViewIdentifier]];
    panel.delegate = delegate;
    [panel updateView];
    return panel;
}
+ (NSString *)getViewIdentifier
{
    return @"DrawMainMenuPanel";
}

- (void)dealloc
{
    PPRelease(_menuList);
//    RELEASE_BLOCK(_finishHandler);
//    RELEASE_BLOCK(_startHandler);
    [super dealloc];
}

- (NSInteger)currentPage
{
    return (NSInteger)([self.scrollView contentOffset].x / CGRectGetWidth(self.scrollView.bounds));
}

#define NUMBER_PER_PAGE 6
#define RADIUS (ISIPAD?300:105)

- (NSArray *)menusInPage:(NSInteger)page
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:NUMBER_PER_PAGE];
    NSInteger i = page *NUMBER_PER_PAGE;
    for (; i < (page+1)*NUMBER_PER_PAGE && i < [self.menuList count]; ++ i) {
        [list addObject:self.menuList[i]];
    }
    return list;
}

- (CGPoint)centerInPage:(NSInteger)page
{
    CGPoint center = self.scrollView.center;
    center.x += page * (CGRectGetWidth(self.scrollView.bounds));
//    center.y += 15;
    return center;
}

- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
                page:(NSInteger)page
{
    [AnimationManager showRoundTypeSettingInView:self.scrollView
                                        subViews:[self menusInPage:page]
                                          center:[self centerInPage:page]
                                          radius:RADIUS
                                        animated:animated
                                      completion:completion];
}


- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
{
    [self openAnimated:animated completion:completion page:[self currentPage]];
}

- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion
                 page:(NSInteger)page
{
    NSArray *menus = [self menusInPage:page];
    CGPoint center = [self centerInPage:page];
    if (animated) {
        [UIView animateWithDuration:MAIN_ANIMATION_INTEVAL animations:^{
        
        for (UIView *menu in menus) {
                menu.center = center;
            }
        } completion:completion];
        
    }else{
        for (UIView *menu in menus) {
            menu.center = center;
        }
    }

}

- (void)centerMenu:(HomeMenuType)type
          Animated:(BOOL)animated
        completion:(void (^)(BOOL finished))completion
{
    HomeMenuView *menu = [self getMenuViewWithType:type];
    CGPoint center = [self centerInPage:[self currentPage]];
    if (animated) {
        [UIView animateWithDuration:MAIN_ANIMATION_INTEVAL animations:^{
            menu.center = center;
        } completion:^(BOOL finished) {
            for (HomeMenuView *menu in self.menuList) {
                menu.hidden = NO;
            }
            EXECUTE_BLOCK(completion,YES);
        }];
    }else{
        menu.center = center;
    }
}

- (void)moveMenuTypeToBottom:(HomeMenuType)type
                    Animated:(BOOL)animated
                  completion:(void (^)(BOOL finished))completion
{
    for (HomeMenuView *menu in self.menuList) {
        menu.hidden = (menu.type != type);
    }
    HomeMenuView *menu = [self getMenuViewWithType:type];
    CGPoint center = [self centerInPage:[self currentPage]];
    CGPoint stopPoint = CGPointMake(center.x, CGRectGetHeight(self.scrollView.bounds)-CGRectGetHeight(menu.bounds)/5);
    if (animated) {
        [UIView animateWithDuration:MAIN_ANIMATION_INTEVAL animations:^{
            menu.center = stopPoint;
        } completion:completion];
    }else{
        menu.center = stopPoint;        
    }
}


- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion

{
    [self closeAnimated:animated completion:completion page:[self currentPage]];
}


- (void)updateView
{
    self.menuList = [NSMutableArray array];
    HomeMenuType *types = getMainMenuTypeList();
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    for (HomeMenuType type = (*types); type != HomeMenuTypeEnd; types++,type=(*types)) {
        PPDebug(@"type = %d",type);
        HomeMenuView *menu = [HomeMenuView menuViewWithType:type badge:0 delegate:self];
        [self.menuList addObject:menu];
    }
    NSInteger pageNumber = [self.menuList count]/NUMBER_PER_PAGE ;
    if (0 != ([self.menuList count] % NUMBER_PER_PAGE)) {
        pageNumber ++;
    }
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds)*pageNumber, CGRectGetHeight(self.scrollView.bounds))];
    for (HomeMenuView *view in self.menuList) {
        [self.scrollView addSubview: view];
    }
    NSInteger page = 0;
    while (page<pageNumber) {
        [self openAnimated:NO completion:NULL page:page];
        page++;
    }
    [self.scrollView bringSubviewToFront:[self getMenuViewWithType:HomeMenuTypeDrawDraw]];
}

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge
{
    [super updateMenu:type badge:badge];
}
- (void)animatePageButtons
{
    [super animatePageButtons];
}
- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type
{
    return [super getMenuViewWithType:type];
}


@end
