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

#define COLUMN 3
#define ACTION_BTN_TAG_OFFSET   20121226
#define WIDTH   280

@interface CustomActionSheet () {
    UIImage* _defaultImage;
}

@property (retain, nonatomic) NSMutableDictionary* buttonImagesDict;
@property (retain, nonatomic) NSMutableArray* buttonTitles;
@property (retain, nonatomic) CMPopTipView* popView;

@end

@implementation CustomActionSheet

- (void)dealloc
{
    [_buttonImagesDict release];
    [_buttonTitles release];
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

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];
    float actionViewWidth = WIDTH/COLUMN;
    
    // init cates show
    int total = self.buttonTitles.count;
#define ROWHEIHT 80
    int rows = (total / COLUMN) + ((total % COLUMN) > 0 ? 1 : 0);
    
    for (int i=0; i<total; i++) {
        int row = i / COLUMN;
        int column = i % COLUMN;
        
        UIView *actionView = [[[UIView alloc] initWithFrame:CGRectMake(actionViewWidth*column, ROWHEIHT*row, actionViewWidth, ROWHEIHT)] autorelease];
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
        
        [self addSubview:actionView];
    }
    
    CGRect viewFrame = self.frame;
    viewFrame.size.height = ROWHEIHT * rows + 19;
    viewFrame.size.width = WIDTH;
    self.frame = viewFrame;
}

- (void)showInView:(UIView *)view onView:(UIView*)onView
{
    [self initView];
    
    if (_popView == nil) {
        _popView = [[CMPopTipView alloc] initWithCustomView:self needBubblePath:NO];
        [_popView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    }
    _popView.hidden = NO;
    [_popView presentPointingAtView:onView inView:view animated:YES];
    self.isVisable = YES;
    
}

- (void)hideActionSheet
{
    _popView.hidden = YES;
    self.isVisable = NO;
}

- (void)subCateBtnAction:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(customActionSheet:clickedButtonAtIndex:)]) {
        [_delegate customActionSheet:self
          clickedButtonAtIndex:btn.tag - ACTION_BTN_TAG_OFFSET];
        
    }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
