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

@interface CustomInfoView()
@property (retain, nonatomic) UIView *infoView;
@end


#define HEIGHT_TOP                  30
#define SPACE_INFOVIEW_AND_TOP      10
#define SPACE_INFOVIEW_AND_BORDER   20

#define HEIGHT_BUTTON               30
#define WIDTH_BUTTON                100
#define SPACE_BUTTON_AND_BUTTON     20

#define WIDTH_INFO_LABEL            210
#define HEIGHT_MIN_INFO_LABEL       100

@implementation CustomInfoView

AUTO_CREATE_VIEW_BY_XIB(CustomInfoView);

- (void)dealloc
{
    [_infoView dealloc];
    [_mainView release];
    [_infoLabel release];
    [_titleLabel release];
    [_closeButton release];
    Block_release(_actionBlock);
    [_scrollView release];
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
    view.mainView.frame = CGRectMake(view.mainView.frame.origin.x, view.mainView.frame.origin.y, view.mainView.frame.size.width, view.infoLabel.frame.origin.y + view.infoLabel.frame.size.height + SPACE_INFOVIEW_AND_BORDER);
    
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
    infoView.frame = CGRectMake(SPACE_INFOVIEW_AND_BORDER, HEIGHT_TOP + SPACE_INFOVIEW_AND_TOP, infoView.frame.size.width, infoView.frame.size.height);
    [view.mainView addSubview:infoView];
    
    view.scrollView.contentSize = CGSizeMake(320, 481);
    
    
    view.infoLabel.hidden = YES;
    
    
    // set close button
    view.closeButton.hidden = !hasCloseButton;
    
    
    // add buttons
    NSMutableArray *titleList = [[[NSMutableArray alloc] init] autorelease];
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

    if ([titleList count] > 0) {
        CGFloat y = HEIGHT_TOP + SPACE_INFOVIEW_AND_TOP + infoView.frame.size.height + SPACE_INFOVIEW_AND_TOP;
        CGFloat x;
        CGFloat buttonWidth = (infoView.frame.size.width - ([titleList count] - 1) * SPACE_BUTTON_AND_BUTTON ) / [titleList count];
        
        int index = 0;
        for (NSString *buttonTitle in titleList) {
            UIButton *button = [self createButton];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            
            x = SPACE_INFOVIEW_AND_BORDER + index * (buttonWidth + SPACE_BUTTON_AND_BUTTON);
            button.frame = CGRectMake(x, y, buttonWidth, button.frame.size.height);
            [button addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [view.mainView addSubview:button];
            
            index ++;
        }
    }
    
    
    // set mainView size
    CGFloat height = HEIGHT_TOP + SPACE_INFOVIEW_AND_TOP + infoView.frame.size.height + 0.7 * SPACE_INFOVIEW_AND_BORDER;
    if ([titleList count] > 0) {
        height += SPACE_INFOVIEW_AND_TOP + HEIGHT_BUTTON;
    }
    CGFloat width = 2 * SPACE_INFOVIEW_AND_BORDER + infoView.frame.size.width;
    view.mainView.frame = CGRectMake(view.mainView.frame.origin.x, view.mainView.frame.origin.y, width, height);
    view.mainView.center = [UIApplication sharedApplication].keyWindow.center;
    
    
    return view;
}

- (void) setActionBlock:(ButtonActionBlock)actionBlock {
    if (_actionBlock != actionBlock) {
        Block_release(_actionBlock);
        _actionBlock = Block_copy(actionBlock);
    }
}

#define COLOR_BUTTON_TITLE  [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:16.0/255.0 alpha:1]
+ (UIButton *)createButton{
    
    UIImage *backgroundImage = [[ShareImageManager defaultManager] dialogButtonBackgroundImage];
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH_BUTTON, HEIGHT_BUTTON)] autorelease];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setTitleColor:COLOR_BUTTON_TITLE forState:UIControlStateNormal];
    
    return button;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
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
