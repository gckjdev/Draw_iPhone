//
//  ChatView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatView.h"
#import "ExpressionManager.h"
#import "ChatViewCell.h"
#import "LocaleUtils.h"
#import "DiceChatMsgManager.h"
#import "GifView.h"
#import "DiceImageManager.h"

#define WIDTH_EXPRESSION_VIEW   ([DeviceDetection isIPAD] ? 68: 34)
#define HEIGHT_EXPRESSION_VIEW WIDTH_EXPRESSION_VIEW

#define WIDTH_EXPRESSION    ([DeviceDetection isIPAD] ? 60: 30)
#define HEIGHT_EXPRESSION WIDTH_EXPRESSION

#define EXPRESSION_COUNT_PER_PAGE ([DeviceDetection isIPAD] ? 5: 5)

@interface ChatView()
{
    ExpressionManager *_expressionManager;
    DiceChatMsgManager *_messageManager;
}

@property (retain, nonatomic) CMPopTipView *popTipView;
//@property (retain, nonatomic) NSTimer *timer;

@end



@implementation ChatView

@synthesize delegate = _delegate;
@synthesize bgImageView = _bgImageView;
@synthesize expressionsHolderView = _expressionsHolderView;
@synthesize messagesHolderView = _messagesHolderView;
@synthesize popTipView = _popTipView;
//@synthesize timer = _timer;

- (void)dealloc
{
    [_expressionsHolderView release];
    [_messagesHolderView release];
    [_popTipView release];
    [_bgImageView release];
    [_expressionsHolderView release];
    [super dealloc];
}


+ (id)createChatView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];;
}

- (void)loadContent
{
    _expressionManager = [ExpressionManager defaultManager];
    _messageManager = [DiceChatMsgManager defaultManager];
    _bgImageView.image = [[DiceImageManager defaultManager] popupBackgroundImage];
    
    [self addExpressions];
}

- (void)addExpressions
{
    int expsCount = [[_expressionManager allKeys] count];
    int pageCount = expsCount / 5 + (expsCount % 5 == 0 ? 0 : 1);
    
    CGRect frame;
    for (int i = 0; i < pageCount; i ++) {
        frame = CGRectMake(_expressionsHolderView.frame.size.width * i, 0, _expressionsHolderView.frame.size.width, _expressionsHolderView.frame.size.height);
        UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
        [self addExpressionsToView:view pageIndex:i];
        [_expressionsHolderView addSubview:view];
    }
}

- (void)addExpressionsToView:(UIView *)view pageIndex:(int)pageIndex
{
    NSArray *allKeys = [_expressionManager allKeys]; 
    
    int start = pageIndex * EXPRESSION_COUNT_PER_PAGE;
    int end = MIN((pageIndex + 1) * EXPRESSION_COUNT_PER_PAGE, [allKeys count]);
    
    CGRect frame;
    CGFloat edge = (_expressionsHolderView.frame.size.width - EXPRESSION_COUNT_PER_PAGE * WIDTH_EXPRESSION_VIEW)/(EXPRESSION_COUNT_PER_PAGE - 1);
    for (int i = start; i < end; i++)
    {
        frame = CGRectMake((WIDTH_EXPRESSION_VIEW + edge) * (i % EXPRESSION_COUNT_PER_PAGE), 0, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);
        UIButton *expression = [self expressionWithFrame:frame key:[allKeys objectAtIndex:i]];
        [view addSubview:expression];
    }
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection
{
    [self dismissAnimated:YES];
//    [self createTimer];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self needBubblePath:NO] autorelease];
    _popTipView.delegate = self;
    _popTipView.backgroundColor = [UIColor clearColor];
    _popTipView.disableTapToDismiss = YES;
    
    [_popTipView presentPointingAtView:view 
                                inView:inView
                          aboveSubView:siblingSubview
                              animated:animated
                        pointDirection:pointDirection];

}

- (void)dismissAnimated:(BOOL)animated
{
    [_popTipView dismissAnimated:YES];
    self.popTipView = nil;
}

- (UIButton *)expressionWithFrame:(CGRect)frame
                        key:(NSString *)key
{
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];

    NSString *filePath = [_expressionManager gifPathForExpression:key];
    GifView *view;
    if (filePath != nil) {
//        [button setBackgroundImage:[[DiceImageManager defaultManager] diceExpressionBgImage] forState:UIControlStateNormal];
        
        CGRect expframe = CGRectMake(0, 0, WIDTH_EXPRESSION, HEIGHT_EXPRESSION);
        view = [[[GifView alloc] initWithFrame:expframe
                                      filePath:filePath
                              playTimeInterval:0.2] autorelease];
        view.userInteractionEnabled = NO;
        view.center = CGPointMake(button.frame.size.width/2, button.frame.size.height/2);
        
        [button addSubview:view];
    }
    
    [button setTitle:key forState:UIControlStateSelected];
    button.titleLabel.textColor = [UIColor clearColor];
    [button addTarget:self action:@selector(clickExpression:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)clickExpression:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *key = [button titleForState:UIControlStateSelected];
    
    if ([_delegate respondsToSelector:@selector(didClickExepression:)]) {
        [_delegate didClickExepression:key];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_messageManager messages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewCell *cell = (ChatViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatViewCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [ChatViewCell createCell:self];
    }
    
    [cell setCellData:[[_messageManager messages] objectAtIndex:indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatViewCell getCellHeight];
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    /* we switch page at %50 across */
//    CGFloat pageWidth = scrollView.frame.size.width;
//    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth +1);
//    _pageControl.currentPage = page;
//}

#pragma mark -
#pragma mark PageControl stuff
- (void)currentPageDidChange:(int)newPage;
{
    // Change the scroll view 
    CGRect frame = self.frame;
    frame.origin.x  = frame.size.width * newPage;
    frame.origin.y = 0;
    [_expressionsHolderView scrollRectToVisible:frame animated:YES];
}

#pragma mark - ChatViewCellDelegate
- (void)didClickMessage:(DiceChatMessage *)message
{
    if ([_delegate respondsToSelector:@selector(didClickMessage:)]) {
        [_delegate didClickMessage:message];
    }
}


- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    if ([_delegate respondsToSelector:@selector(didChatViewDismiss)]) {
        [_delegate didChatViewDismiss];
    }
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismissAnimated:YES];

}

#pragma mark - Timer manage

//- (void)createTimer
//{
//    [self killTimer];
//    
//    PPDebug(@"self count: %d", self.retainCount);
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
//                                                  target:self 
//                                                selector:@selector(handleTimer:)
//                                                userInfo:nil 
//                                                 repeats:NO];
//    
//    PPDebug(@"self count: %d", self.retainCount);
//}
//
//- (void)killTimer
//{
//    if ([_timer isValid]) {
//        [_timer invalidate];        
//    }
//    self.timer = nil;
//}
//
//- (void)handleTimer:(NSTimer *)timer
//{
//    [self dismissAnimated:YES];
//}


@end
