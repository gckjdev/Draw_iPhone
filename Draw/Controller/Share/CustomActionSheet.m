//
//  CustomActionSheet.m
//  Draw
//
//  Created by Kira on 12-12-26.
//
//

#import "CustomActionSheet.h"
#import <UIKit/UIKit.h>
#import "CMPopTipView.h"
#import "StringUtil.h"

#import "HGQuadCurveMenuItem.h"

#define DEFAULT_COLUMN 3
#define ACTION_BTN_TAG_OFFSET   20121226
#define DEFAULT_WIDTH   280
#define DEFAULT_ROWHEIHT 80

@interface CustomActionSheet () {
    UIImage* _defaultImage;
}

@property (retain, nonatomic) NSMutableDictionary* buttonImagesDict;
@property (retain, nonatomic) NSMutableArray* buttonTitles;
@property (retain, nonatomic) NSMutableDictionary* badgeCountDict;
@property (retain, nonatomic) CMPopTipView* popView;
@property (retain, nonatomic) HGQuadCurveMenu* menu;

@end

@implementation CustomActionSheet

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [_buttonImagesDict release];
    [_buttonTitles release];
    [_badgeCountDict release];
    PPRelease(_popView);
    PPRelease(_menu);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIImage*)defaultActionImage
{
    if (_defaultImage == nil) {
        _defaultImage = [[[UIImage alloc] init] autorelease];
    }
    return _defaultImage;
}

- (NSInteger)addButtonWithTitle:(NSString *)title image:(UIImage*)image
{
    UIImage* anImage = (image == nil)?[self defaultActionImage]:image;
    if (title != nil) {
        [self.buttonTitles addObject:title];
        [self.buttonImagesDict setObject:anImage forKey:title];
    }
    return self.buttonTitles.count;
}

- (void)setImage:(UIImage*)image forTitle:(NSString*)title
{
    if (image != nil && title != nil) {
        [self.buttonImagesDict setObject:image forKey:title];
    }
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < self.buttonTitles.count) {
        return [self.buttonTitles objectAtIndex:buttonIndex];
    }
    return nil;
}
- (UIImage*)buttonImageAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < self.buttonTitles.count) {
        return [self.buttonImagesDict objectForKey:[self.buttonTitles objectAtIndex:buttonIndex]];
    }
    return nil;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated NS_AVAILABLE_IOS(3_2)
{
    
}

- (UIView*)createShowView
{
    UIView* showView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
    showView.backgroundColor = [UIColor clearColor];
    float actionViewWidth = DEFAULT_WIDTH/DEFAULT_COLUMN;
    
    // init cates show
    int total = self.buttonTitles.count;

    int rows = (total / DEFAULT_COLUMN) + ((total % DEFAULT_COLUMN) > 0 ? 1 : 0);
    
    for (int i=0; i<total; i++) {
        int row = i / DEFAULT_COLUMN;
        int column = i % DEFAULT_COLUMN;
        
        UIView *actionView = [[[UIView alloc] initWithFrame:CGRectMake(actionViewWidth*column, DEFAULT_ROWHEIHT*row, actionViewWidth, DEFAULT_ROWHEIHT)] autorelease];
        actionView.backgroundColor = [UIColor clearColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15, 15, 50, 50);
        btn.tag = i + ACTION_BTN_TAG_OFFSET;
        [btn addTarget:self
                action:@selector(subCateBtnAction:)
      forControlEvents:UIControlEventTouchUpInside];
        [btn setCenter:CGPointMake(actionViewWidth/2, btn.center.y)];
        
        
        [btn setBackgroundImage:(UIImage*)[self.buttonImagesDict objectForKey:[self.buttonTitles objectAtIndex:i]]
                       forState:UIControlStateNormal];
        
        [actionView addSubview:btn];
        
        UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 65, actionViewWidth, 14)] autorelease];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.textColor = [UIColor colorWithRed:204/255.0
                                        green:204/255.0
                                         blue:204/255.0
                                        alpha:1.0];
        lbl.font = [UIFont systemFontOfSize:12.0f];
        [lbl setTextAlignment:UITextAlignmentCenter];
        [lbl setTextColor:[UIColor whiteColor]];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = (NSString*)[self.buttonTitles objectAtIndex:i];
        [actionView addSubview:lbl];
        
        [showView addSubview:actionView];
    }
    
    CGRect viewFrame = showView.frame;
    viewFrame.size.height = DEFAULT_ROWHEIHT * rows + 19;
    viewFrame.size.width = DEFAULT_WIDTH;
    showView.frame = viewFrame;
    return showView;
}

- (UIView*)createShowViewWithContainerSize:(CGSize)size
                                   columns:(int)columns
                                showTitles:(BOOL)shouldShowTitles
                                  itemSize:(CGSize)itemSize
                           backgroundImage:(UIImage*)backgroundImage
{
    UIView* showView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
    showView.backgroundColor = [UIColor clearColor];
    float actionViewWidth = itemSize.width;
    float actionViewHeight = itemSize.height*(shouldShowTitles?1.2:1);
    
    // init cates show
    int total = self.buttonTitles.count;
    
    int rows = (total / columns) + ((total % columns) > 0 ? 1 : 0);
    
    //cal total size
    float totalWidth = itemSize.width*(columns*1 + 0);
    float totalHeight = itemSize.height*(rows*1+0)*(shouldShowTitles?1.2:1);
    
    if (totalWidth > size.width || totalHeight > size.height) {
        //use scroll view
    } else {
        //just add
        for (int i=0; i<total; i++) {
            int row = i / columns;
            int column = i % columns;
            
            UIView *actionView = [[[UIView alloc] initWithFrame:CGRectMake(actionViewWidth*column, actionViewHeight*row, actionViewWidth, actionViewHeight)] autorelease];
            actionView.backgroundColor = [UIColor clearColor];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btn.frame = CGRectMake(0.1*actionViewWidth, 0.1*actionViewHeight, itemSize.width*0.8, itemSize.height*0.8);
            btn.tag = i + ACTION_BTN_TAG_OFFSET;
            [btn addTarget:self
                    action:@selector(subCateBtnAction:)
          forControlEvents:UIControlEventTouchUpInside];
//            [btn setCenter:CGPointMake(actionViewWidth/2, actionViewHeight/2)];
            
            [btn setBackgroundImage:(UIImage*)[self.buttonImagesDict objectForKey:[self.buttonTitles objectAtIndex:i]]
                           forState:UIControlStateNormal];
            
            [actionView addSubview:btn];
            if (shouldShowTitles) {
                UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, actionViewWidth, actionViewWidth, actionViewHeight*0.2)] autorelease];
                lbl.textAlignment = UITextAlignmentCenter;
                lbl.textColor = [UIColor colorWithRed:204/255.0
                                                green:204/255.0
                                                 blue:204/255.0
                                                alpha:1.0];
                lbl.font = [UIFont systemFontOfSize:12.0f];
                lbl.backgroundColor = [UIColor clearColor];
                lbl.text = (NSString*)[self.buttonTitles objectAtIndex:i];
                [actionView addSubview:lbl];
            }
            
            int badgeCount = [self badgeCountForIndex:i];
            if (badgeCount > 0) {
                UIButton *badge = [[[UIButton alloc] initWithFrame:CGRectMake(actionViewWidth*0.6, 0, actionViewWidth*0.4, actionViewWidth*0.4)] autorelease];
                badge.titleLabel.textAlignment = UITextAlignmentCenter;
                badge.titleLabel.font = [UIFont systemFontOfSize:actionViewWidth/5];
                [badge setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [badge setBackgroundImage:[UIImage imageNamed:@"common_home_badge.png"] forState:UIControlStateNormal];
                [badge setTitle:[NSString stringWithFormat:@"%d", badgeCount] forState:UIControlStateNormal];
                [actionView addSubview:badge];
            }
            
            
            
            [showView addSubview:actionView];
        }
        
        CGRect viewFrame = showView.frame;
        viewFrame.size.height = totalHeight + 0.2*actionViewHeight;
        viewFrame.size.width = totalWidth;
        showView.frame = viewFrame;
    }
    if (backgroundImage) {
        UIImageView* view = [[UIImageView alloc] initWithFrame:showView.frame];
        [view setImage:backgroundImage];
        [showView addSubview:view];
        [showView sendSubviewToBack:view];
    }
    
    return showView;
}

- (void)showInView:(UIView *)view
            onView:(UIView*)onView
 WithContainerSize:(CGSize)size
           columns:(int)columns
        showTitles:(BOOL)shouldShowTitles
          itemSize:(CGSize)itemSize
   backgroundImage:(UIImage*)backgroundImage
{
    
    self.popView = [[[CMPopTipView alloc] initWithCustomViewWithoutBubble:[self createShowViewWithContainerSize:size columns:columns showTitles:shouldShowTitles itemSize:itemSize backgroundImage:backgroundImage]] autorelease];
    _popView.hidden = NO;
    [_popView presentPointingAtView:onView inView:view animated:YES];
    self.isVisable = YES;
    
}

- (void)expandInView:(UIView *)view
              onView:(UIView*)onView
           fromAngle:(float)fromAngle
             toAngle:(float)toAngle
              radius:(float)radius
            itemSize:(CGSize)size
          
{
    if (_menu == nil) {
        NSMutableArray* itemArray = [[[NSMutableArray alloc] init] autorelease];
        for (NSString* title in self.buttonTitles) {
            UIImage* image = (UIImage*)[self.buttonImagesDict objectForKey:title];
            HGQuadCurveMenuItem* item = [[[HGQuadCurveMenuItem alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) image:image highlightedImage:image contentImage:nil highlightedContentImage:nil title:title] autorelease];
            [itemArray addObject:item];
        }
        self.menu = [[[HGQuadCurveMenu alloc] initWithFrame:onView.frame menus:itemArray nearRadius:radius*0.9 endRadius:radius farRadius:radius*1.1 startPoint:CGPointMake(onView.bounds.size.width/2, onView.bounds.size.height+size.height) timeOffset:0.036 rotateAngle:fromAngle menuWholeAngle:(toAngle - fromAngle) buttonImage:nil buttonHighLightImage:nil contentImage:nil contentHighLightImage:nil] autorelease];
        _menu.delegate = self;
        [view addSubview:_menu];
    }
    
    [view insertSubview:_menu aboveSubview:onView];
    [self.menu expandItems];
    self.isVisable = YES;
    
}

- (void)showInView:(UIView *)view onView:(UIView*)onView
{
    
    if (_popView == nil) {
        _popView = [[CMPopTipView alloc] initWithCustomView:[self createShowView] needBubblePath:NO];
        
    }
    _popView.hidden = NO;
    [_popView presentPointingAtView:onView inView:view animated:YES];
    self.isVisable = YES;
    
}

- (void)hideActionSheet
{
    _popView.hidden = YES;
    if (_menu && _menu.isExpanding) {
        [_menu closeItems];
    }
    self.isVisable = NO;
}

- (void)subCateBtnAction:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(customActionSheet:clickedButtonAtIndex:)]) {
        [_delegate customActionSheet:self
          clickedButtonAtIndex:btn.tag - ACTION_BTN_TAG_OFFSET];
    }
    [self setBadgeCount:0 forIndex:btn.tag-ACTION_BTN_TAG_OFFSET];
    [self hideActionSheet];
}

- (id)initWithTitle:(NSString *)title
           delegate:(id<CustomActionSheetDelegate>)delegate
       buttonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION 
{
    self = [super init];
    if (self) {
        id eachTitle;
        va_list argumentList;
        self.delegate = delegate;
        
        _buttonImagesDict = [[NSMutableDictionary alloc] initWithCapacity:30];
        _buttonTitles = [[NSMutableArray alloc] initWithCapacity:30];
        
        if (otherButtonTitles) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [self addButtonWithTitle:otherButtonTitles image:nil];
            va_start(argumentList, otherButtonTitles); // Start scanning for arguments after firstObject.
            while ((eachTitle = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
                [self addButtonWithTitle:eachTitle image:nil]; // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
           delegate:(id<CustomActionSheetDelegate>)delegate
         imageArray:(UIImage *)otherBtnImages, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super init];
    if (self) {
        id eachImage;
        va_list argumentList;
        self.delegate = delegate;
        
        _buttonImagesDict = [[NSMutableDictionary alloc] initWithCapacity:30];
        _buttonTitles = [[NSMutableArray alloc] initWithCapacity:30];
        
        int i = 20130509;
        if (otherBtnImages) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [self addButtonWithTitle:[NSString stringWithInt:i] image:otherBtnImages];
            va_start(argumentList, otherBtnImages); // Start scanning for arguments after firstObject.
            while ((eachImage = va_arg(argumentList, id))){ // As many times as we can get an argument of type "id"
                i++;
                [self addButtonWithTitle:[NSString stringWithInt:i] image:eachImage]; // that isn't nil, add it to self's contents.
                
            }
            va_end(argumentList);
        }
    }
    return self;
}

#pragma mark - HGQuadCurveMenu Delegate
- (void)quadCurveMenu:(HGQuadCurveMenu *)menu didSelectIndex:(NSInteger)anIndex
{
    self.isVisable = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(customActionSheet:clickedButtonAtIndex:)]) {
        [_delegate customActionSheet:self clickedButtonAtIndex:anIndex];
        PPDebug(@"<quadCurveMenu>did click button at index %d", anIndex);
    }
    
}

- (void)quadCurveMenuDidExpand
{
    self.isVisable = YES;
}
- (void)quadCurveMenuDidClose
{
    self.isVisable = NO;
}

- (void)setBadgeCount:(int)count
             forIndex:(int)index
{
    NSString* title = [self buttonTitleAtIndex:index];
    if (title == nil) {
        return;
    }
    if (_badgeCountDict == nil) {
        self.badgeCountDict = [[[NSMutableDictionary alloc] init] autorelease];
    }
    [self.badgeCountDict setObject:@(count) forKey:title];
    
}
- (int)badgeCountForIndex:(int)index
{
    NSString* title = [self buttonTitleAtIndex:index];
    NSNumber* number = ((NSNumber*)[self.badgeCountDict objectForKey:title]);
    if (number) {
        return number.intValue;
    }
    return 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
