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
#import "StableView.h"

@interface DrawMainMenuPanel()
@property(nonatomic, retain)NSMutableArray *menuList;
@end

@implementation DrawMainMenuPanel

#define SELF_FRAME (ISIPAD?CGRectMake(0, 0, 768, 804):CGRectMake(0, 0, 320, 360+(ISIPHONE5?78:0)))
+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    DrawMainMenuPanel *panel = [[[DrawMainMenuPanel alloc] initWithFrame:SELF_FRAME] autorelease];
    panel.delegate = delegate;
    [panel baseInit];
    return panel;
}
+ (NSString *)getViewIdentifier
{
    return @"DrawMainMenuPanel";
}

- (void)dealloc
{
    PPRelease(_menuList);
    [super dealloc];
}

- (NSInteger)currentPage
{
    NSInteger page = (NSInteger)([self.scrollView contentOffset].x / CGRectGetWidth(self.scrollView.bounds));
    return page;
}

#define NUMBER_PER_PAGE 6
#define RADIUS (ISIPAD?250:105+(ISIPHONE5?5:0))

- (NSArray *)menusInPage:(NSInteger)page
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:NUMBER_PER_PAGE];
    NSInteger i = page *NUMBER_PER_PAGE;
    for (; i < (page+1)*NUMBER_PER_PAGE && i < [self.menuList count]; ++ i) {
        [list addObject:self.menuList[i]];
    }
    return list;
}

#define CENTER_OFFSET (ISIPAD?38:17)
- (CGPoint)centerInPage:(NSInteger)page
{
    CGPoint center = self.scrollView.center;
    center.x += page * (CGRectGetWidth(self.scrollView.bounds));
    center.y -= CENTER_OFFSET;
    return center;
}



#define TAG_OFFSET 1000000

- (void)showAllLinesInCurrentPage
{
    NSArray *menus = [self menusInPage:[self currentPage]];
    for (HomeMenuView *menu in menus) {
        UIView *line = [self.scrollView viewWithTag:menu.tag+TAG_OFFSET];
        line.hidden = NO;
    }
}

- (void)hideAllLinesInCurrentPage
{
    NSArray *menus = [self menusInPage:[self currentPage]];
    for (HomeMenuView *menu in menus) {
        UIView *line = [self.scrollView viewWithTag:menu.tag+TAG_OFFSET];
        line.hidden = YES;
    }
}

- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
                page:(NSInteger)page
{
    NSArray *menus = [self menusInPage:page];
    [menus[0] toBeTitleUpStyle];
    
    UIImage *lineImage = nil;
    if (ISIPAD) {
        lineImage = [UIImage imageNamed:@"common_home_join_line@2x.png"];
    }else{
        lineImage = [UIImage imageNamed:@"common_home_join_line.png"];
    }
    lineImage = [lineImage stretchableImageWithLeftCapWidth:lineImage.size.width/2 topCapHeight:lineImage.size.height/2];
    
    [self performSelector:@selector(showAllLinesInCurrentPage) withObject:nil afterDelay:MAIN_ANIMATION_INTEVAL/1.5];
    [AnimationManager showRoundTypeSettingInView:self.scrollView
                                        subViews:menus
                                            line:lineImage
                                          center:[self centerInPage:page]
                                          radius:RADIUS
                                        animated:animated
                                      completion:completion];    
}

- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
    
    [self openAnimated:animated completion:^(BOOL finished) {
        EXECUTE_BLOCK(completion,YES);
        [self.scrollView enumSubviewsWithClass:[HomeMenuView class] handler:^(id view) {
            HomeMenuView *menu = view;
            [menu.title setHidden:NO];
            
        }];
        //show views after open.
        [self updateAvatar];
        [self updatePageButton];
        
    } page:[self currentPage]];
}



- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion
                 page:(NSInteger)page
{
    NSArray *menus = [self menusInPage:page];
    CGPoint center = [self centerInPage:page];

    //hide views before close
    [self hidePageButtons];
    [self.scrollView enumSubviewsWithClass:[HomeMenuView class] handler:^(id view) {
        HomeMenuView *menu = view;
        [menu.title setHidden:YES];
    }];
    [[self badgeViewInPage:0] setHidden:YES];
    [[self badgeViewInPage:1] setHidden:YES];
    
    [self performSelector:@selector(hideAllLinesInCurrentPage) withObject:nil afterDelay:MAIN_ANIMATION_INTEVAL/2.];

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
        EXECUTE_BLOCK(completion,YES);
    }

}

- (void)centerMenu:(HomeMenuType)type
          Animated:(BOOL)animated
        completion:(void (^)(BOOL finished))completion
{
    self.scrollView.scrollEnabled = YES;
    
    HomeMenuView *menu = [self getMenuViewWithType:type];
    [menu.title setHidden:YES];
    CGPoint center = [self centerInPage:[self currentPage]];
    if (animated) {
        [UIView animateWithDuration:MAIN_ANIMATION_INTEVAL animations:^{
            menu.center = center;
        } completion:^(BOOL finished) {
            for (HomeMenuView *menu in self.menuList) {
                menu.hidden = NO;
            }
            [self.scrollView enumSubviewsWithClass:[AvatarView class] handler:^(id view) {
                [(AvatarView *)view setHidden:NO];
            }];
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
    self.scrollView.scrollEnabled = NO;    
    for (HomeMenuView *menu in self.menuList) {
        menu.hidden = (menu.type != type);
    }
    [self.scrollView enumSubviewsWithClass:[AvatarView class] handler:^(id view) {
        [(AvatarView *)view setHidden:YES];
    }];
    
    HomeMenuView *menu = [self getMenuViewWithType:type];
    [menu toBeTitleDownStyle];
    CGPoint center = [self centerInPage:[self currentPage]];
    CGPoint stopPoint = CGPointMake(center.x, CGRectGetHeight(self.scrollView.bounds)-CGRectGetHeight(menu.bounds)/2);
    if (!ISIPAD&&!ISIPHONE5) {
        stopPoint.y += 10;
    }
    if (animated) {
        [UIView animateWithDuration:MAIN_ANIMATION_INTEVAL animations:^{
            menu.center = stopPoint;
        } completion:^(BOOL finished) {
            EXECUTE_BLOCK(completion,YES);
//            menu.title.hidden = NO;
        }];
    }else{
        menu.center = stopPoint;
        EXECUTE_BLOCK(completion,YES);        
//        menu.title.hidden = NO;
    }
}


- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion

{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [self closeAnimated:animated completion:completion page:[self currentPage]];
}


#define AVATAR_SIZE (ISIPAD?CGSizeMake(150,150):CGSizeMake(70,70))
#define DEFAULT_AVATAR_SIZE (ISIPAD?CGSizeMake(142,172):CGSizeMake(76,92))

- (void)addAvatarInPage:(NSInteger)page
{
    UserManager *me = [UserManager defaultManager];
    AvatarView *av = [[AvatarView alloc] initWithUrlString:nil frame:CGRectMake(0, 0, AVATAR_SIZE.width, AVATAR_SIZE.height) gender:[me gender] level:[me level]];
    
    [self.scrollView insertSubview:av atIndex:0];
    av.delegate = self;
    [av release];
    av.center = [self centerInPage:page];
}


- (void)updateViewLayers
{
    __block UIView *topLine = nil;
    [self.scrollView enumSubviewsWithClass:[UIImageView class] handler:^(id view) {
        topLine = view;
    }];
    
    [self.scrollView enumSubviewsWithClass:[AvatarView class] handler:^(id view) {
        AvatarView *avatar = view;
        [self.scrollView insertSubview:avatar aboveSubview:topLine];
    }];

}

#define MENU_TAG_BASE 10000
#define PAGE_BUTTON_SIZE (ISIPAD?CGSizeMake(80,80):CGSizeMake(40,40))
#define PAGE_BUTTON_CENTER_Y (ISIPAD?680:300+(ISIPHONE5?80:0))

- (void)pageInit
{
    self.previous = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.previous setImage:[SIM previousPage] forState:UIControlStateNormal];
    self.previous.frame = CGRectMake(0, 0, PAGE_BUTTON_SIZE.width, PAGE_BUTTON_SIZE.height);
    [self.previous updateCenterY:PAGE_BUTTON_CENTER_Y];
    [self.previous updateCenterX:PAGE_BUTTON_SIZE.width/2];
    [self addSubview:self.previous];
    [self.previous addTarget:self action:@selector(clickPageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.next = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.next setImage:[SIM nextPage] forState:UIControlStateNormal];
    self.next.frame = CGRectMake(0, 0, PAGE_BUTTON_SIZE.width, PAGE_BUTTON_SIZE.height);
    [self.next updateCenterY:PAGE_BUTTON_CENTER_Y];
    [self.next updateCenterX:(CGRectGetWidth(self.bounds))-PAGE_BUTTON_SIZE.width/2];
    [self addSubview:self.next];
    [self.next addTarget:self action:@selector(clickPageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updatePageButton];
    [self animatePageButtons];
}

- (void)baseInit
{
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    self.scrollView.autoresizingMask = (0x1<<6)-1;
    [self addSubview:self.scrollView];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setDelegate:self];
    
    self.menuList = [NSMutableArray array];
    HomeMenuType *types = getMainMenuTypeList();
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    NSInteger tag = MENU_TAG_BASE;
    for (HomeMenuType type = (*types); type != HomeMenuTypeEnd; types++,type=(*types)) {
        HomeMenuView *menu = [HomeMenuView menuViewWithType:type badge:0 delegate:self];
        menu.tag = tag++;
        [self.menuList addObject:menu];
    }
    NSInteger pageNumber = [self.menuList count]/NUMBER_PER_PAGE ;
    if (0 != ([self.menuList count] % NUMBER_PER_PAGE)) {
        pageNumber ++;
    }
    self.pageCount = pageNumber;
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds)*pageNumber, CGRectGetHeight(self.scrollView.bounds))];
    for (HomeMenuView *view in self.menuList) {
        [self.scrollView addSubview: view];
    }
    NSInteger page = 0;
    while (page<pageNumber) {
        //add avatar
        [self addAvatarInPage:page];
        [self openAnimated:NO completion:NULL page:page];
        page++;
    }
    [self updateAvatar];
    [self updateViewLayers];
    [self.scrollView bringSubviewToFront:[self getMenuViewWithType:HomeMenuTypeDrawDraw]];
    [self pageInit];
}

- (void)updateView
{
    [self updateAvatar];
}

#define AVATAR_VIEW_TAG_BASE 93475
- (BadgeView *)badgeViewInPage:(NSInteger)page
{
    return (id)[self.scrollView viewWithTag:AVATAR_VIEW_TAG_BASE+page];
}

#define AVATAR_INSET (ISIPAD?CGSizeMake(12, 12):CGSizeMake(6, 6))

- (void)updateAvatar
{
    UserManager *me = [UserManager defaultManager];
    __block NSInteger index = 0;
    [self.scrollView enumSubviewsWithClass:[AvatarView class] handler:^(id view) {
        AvatarView *av = view;
        if (([me.avatarURL length] != 0)) {
            [av setAsRound];
            av.layer.borderColor = [COLOR_BROWN CGColor];
            av.layer.borderWidth = 0;
            av.frame = CGRectMake(0, 0, AVATAR_SIZE.width, AVATAR_SIZE.height);
            [av setAvatarUrl:me.avatarURL gender:me.gender];
            [av setBackgroundImage:[SIM homeDefaultAvatarBG]];
            [av setContentInset:AVATAR_INSET];
        }else{
            [av setImage:[[ShareImageManager defaultManager] homeDefaultAvatar]];
            av.layer.borderWidth = 0;
            av.frame = CGRectMake(0, 0, DEFAULT_AVATAR_SIZE.width, DEFAULT_AVATAR_SIZE.height);
            [av setContentInset:CGSizeZero];
            [av setBackgroundImage:nil];
            [av setAsSquare];
        }
        
        av.center = [self centerInPage:index];
        
        BadgeView *badgeView = [self badgeViewInPage:index];
        NSInteger badge = [[UserManager defaultManager] getUserBadgeCount];
        if (badgeView == nil) {
            badgeView = [BadgeView badgeViewWithNumber:badge];
            badgeView.tag = AVATAR_VIEW_TAG_BASE+index;
            [self.scrollView addSubview:badgeView];;
        }
        [badgeView updateOriginX:(CGRectGetMaxX(av.frame)-CGRectGetWidth(badgeView.bounds))];
        [badgeView updateOriginY:(CGRectGetMinY(av.frame))];
        [badgeView setNumber:badge];
        
        index++;
    }];
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

- (void)didClickOnAvatar:(NSString *)userId
{
    __block AvatarView * avatar = nil;
    [self.scrollView enumSubviewsWithClass:[AvatarView class] handler:^(id view) {
        avatar = view;
    }];
    if ([self.delegate respondsToSelector:@selector(homeMainMenuPanel:didClickAvatarView:)]) {
        [self.delegate homeMainMenuPanel:self didClickAvatarView:avatar];
    }
}



@end
