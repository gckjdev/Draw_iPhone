//
//  CustomInfoView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-5.
//
//

#import "CustomInfoView.h"
#import "AutoCreateViewByXib.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"
#import "AnimationManager.h"

@interface CustomInfoView()
@property (retain, nonatomic) UIView *infoView;
@end


#define TITLE_HEIGHT                30
#define SPACE_VERTICAL              10
#define SPACE_HORIZONTAL            20

#define BUTTON_HEIGHT               30
#define BUTTON_WIDTH                100
#define SPACE_BUTTON_AND_BUTTON     20

#define WIDTH_INFO_LABEL            210
#define HEIGHT_MIN_INFO_LABEL       100

@implementation CustomInfoView

AUTO_CREATE_VIEW_BY_XIB(CustomInfoView);

- (void)dealloc
{
    [_infoView release];
    [_mainView release];
    [_infoLabel release];
    [_titleLabel release];
    [_closeButton release];
    Block_release(_actionBlock);
    [super dealloc];
}

+ (id)createWithTitle:(NSString *)title
                 info:(NSString *)info
{
    CustomInfoView *view = [self createView];
    view.titleLabel.text = title;
    view.infoLabel.text = info;
    
    // set info label height
    CGSize maxSize = CGSizeMake(WIDTH_INFO_LABEL, 400);
    CGSize size = [view.infoLabel.text sizeWithFont:view.infoLabel.font constrainedToSize:maxSize];
    if (size.height < HEIGHT_MIN_INFO_LABEL) {
        size = CGSizeMake(size.width, HEIGHT_MIN_INFO_LABEL);
    }
    view.infoLabel.frame = CGRectMake(view.infoLabel.frame.origin.x, view.infoLabel.frame.origin.y, WIDTH_INFO_LABEL, size.height);
    
    // set mainView height
    view.mainView.frame = CGRectMake(view.mainView.frame.origin.x, view.mainView.frame.origin.y, view.mainView.frame.size.width, view.infoLabel.frame.origin.y + view.infoLabel.frame.size.height + SPACE_HORIZONTAL);
    
    return view;
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
{
    return [self createWithTitle:title infoView:infoView hasCloseButton:YES buttonTitles:nil];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSString *)firstTitle, ...
{
    CustomInfoView *view = [self createView];
    
    view.infoView = infoView;
    
    // set mainView size
    CGFloat width = SPACE_HORIZONTAL + infoView.frame.size.width + SPACE_HORIZONTAL;
    CGFloat height = TITLE_HEIGHT + SPACE_VERTICAL + infoView.frame.size.height + SPACE_VERTICAL;
    [view.mainView updateWidth:width];
    [view.mainView updateHeight:height];
        
    // set title
    view.titleLabel.text = title;
    
    // add info view
    [infoView updateOriginX:SPACE_HORIZONTAL];
    [infoView updateOriginY:(TITLE_HEIGHT + SPACE_VERTICAL)];
    [view.mainView addSubview:infoView];
    
    view.infoLabel.hidden = YES;
    
    // set close button
    view.closeButton.hidden = !hasCloseButton;
    
    // add buttons
    NSMutableArray *titleList = [NSMutableArray array];
    id arg;
    va_list argList;
    if (firstTitle)
    {
        [titleList addObject:firstTitle];
        va_start(argList, firstTitle);
        while ((arg = va_arg(argList,id)))
        {
            [titleList addObject:arg];
        }
        va_end(argList);
    }
    
    CGFloat originY = TITLE_HEIGHT + SPACE_VERTICAL + infoView.frame.size.height + SPACE_VERTICAL;

    if ([titleList count] != 0) {
        [view.mainView updateHeight:(view.mainView.frame.size.height + SPACE_VERTICAL + BUTTON_HEIGHT)];
    }
    
    if ([titleList count] == 1) {
        UIButton *button = [self createButtonWithTitle:[titleList objectAtIndex:0]];
        [button updateCenterX:infoView.center.x];
        [button updateOriginY:originY];
        [button addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        
        [view.mainView addSubview:button];
    }
    
    if ([titleList count] >= 2) {
        UIButton *button1 = [self createButtonWithTitle:[titleList objectAtIndex:0]];
        UIButton *button2 = [self createButtonWithTitle:[titleList objectAtIndex:1]];
        [button1 updateOriginX:infoView.frame.origin.x];
        [button1 updateOriginY:originY];
        [button1 addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button1.tag = 0;

        [button2 updateOriginX:(infoView.frame.origin.x + infoView.frame.size.width - button2.frame.size.width)];
        [button2 updateOriginY:originY];
        [button2 addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button2.tag = 1;

        [view.mainView addSubview:button1];
        [view.mainView addSubview:button2];
    }
    
    [view.mainView updateCenterY:(view.center.y - 10)];
    
    return view;
}

- (void) setActionBlock:(ButtonActionBlock)actionBlock {
    if (_actionBlock != actionBlock) {
        Block_release(_actionBlock);
        _actionBlock = Block_copy(actionBlock);
    }
}

#define COLOR_BUTTON_TITLE  [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:16.0/255.0 alpha:1]

+ (UIButton *)createButtonWithTitle:(NSString *)title{
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
    [button setBackgroundImage:[[ShareImageManager defaultManager] dialogButtonBackgroundImage] forState:UIControlStateNormal];
    [button setTitleColor:COLOR_BUTTON_TITLE forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    return button;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self.layer addAnimation:[AnimationManager moveVerticalAnimationFrom:(self.superview.frame.size.height*1.5) to:(self.superview.frame.size.height*0.5) duration:0.3] forKey:@""];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (_actionBlock) {
        _actionBlock(button, _infoView);
    }
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismiss];
}

@end
