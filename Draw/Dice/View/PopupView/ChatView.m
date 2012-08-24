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

#define POPTIPVIEW_BG_COLOR [UIColor colorWithRed:177./255. green:218./255. blue:199./255. alpha:0.9]

#define WIDTH_CHAT_VIEW 230
#define HEIGHT_CHAT_VIEW 225

#define WIDTH_EXPRESSION_HOLDER_VIEW WIDTH_CHAT_VIEW
#define HEIGHT_EXPRESSION_HOLDER_VIEW 34

#define WIDTH_MESSAGE_HOLDER_VIEW WIDTH_CHAT_VIEW
#define HEIGHT_MESSAGE_HOLDER_VIEW 188

#define WIDTH_EXPRESSION_VIEW 34
#define HEIGHT_EXPRESSION_VIEW WIDTH_EXPRESSION_VIEW

#define WIDTH_EXPRESSION 30
#define HEIGHT_EXPRESSION WIDTH_EXPRESSION

#define EDGE_BETWEEN_EXPRESSIONS 8

#define EDGE_BETWEEN_EXPREESIONS_HOLDER_VIEW_AND_MESSAGES_HOLDER_VIEW 8

#define ORIGIN_X_EXPRESSIONS_HOLDER_VIEW 10
#define ORIGIN_X_MESSAGES_HOLDER_VIEW ORIGIN_X_EXPRESSIONS_HOLDER_VIEW

#define EXPRESSION_COUNT_PER_PAGE 5

@interface ChatView()
{
    ExpressionManager *_expressionManager;
}

@property (retain, nonatomic) UIScrollView *expressionsHolderView;
@property (retain, nonatomic) UICustomPageControl *pageControl;
@property (retain, nonatomic) UITableView *messagesHolderView;
@property (retain, nonatomic) NSArray *messages;
@property (retain, nonatomic) CMPopTipView *popTipView;

@end



@implementation ChatView

@synthesize delegate = _delegate;
@synthesize expressionsHolderView = _expressionsHolderView;
@synthesize pageControl = _pageControl;
@synthesize messagesHolderView = _messagesHolderView;
@synthesize messages = _messages;
@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_expressionsHolderView release];
    [_pageControl release];
    [_messagesHolderView release];
    [_messages release];
    [_popTipView release];
    [super dealloc];
}

- (id)init
{
    CGRect frame = CGRectMake(0, 0, WIDTH_CHAT_VIEW, HEIGHT_CHAT_VIEW);
    if (self = [super initWithFrame:frame]) {
        CGRect expsHolderViewFrame = CGRectMake(ORIGIN_X_EXPRESSIONS_HOLDER_VIEW, 0, WIDTH_EXPRESSION_HOLDER_VIEW, HEIGHT_EXPRESSION_HOLDER_VIEW);
        self.expressionsHolderView = [[[UIScrollView alloc] initWithFrame:expsHolderViewFrame] autorelease];
        _expressionsHolderView.pagingEnabled = YES;
        _expressionsHolderView.showsVerticalScrollIndicator = NO;
        _expressionsHolderView.showsHorizontalScrollIndicator = NO;
        _expressionsHolderView.backgroundColor = [UIColor clearColor];
        _expressionsHolderView.delegate = self;
        
        self.pageControl = [[[UICustomPageControl alloc] initWithFrame:CGRectZero] autorelease]; 
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.delegate = self;
        
        [self addSubview:_expressionsHolderView];
        [self addSubview:_pageControl];
        
        CGRect msgsHolderViewFrame = CGRectMake(ORIGIN_X_MESSAGES_HOLDER_VIEW, HEIGHT_EXPRESSION_HOLDER_VIEW + EDGE_BETWEEN_EXPREESIONS_HOLDER_VIEW_AND_MESSAGES_HOLDER_VIEW, WIDTH_MESSAGE_HOLDER_VIEW, HEIGHT_MESSAGE_HOLDER_VIEW);
        self.messagesHolderView = [[[UITableView alloc] initWithFrame:msgsHolderViewFrame style:UITableViewStylePlain] autorelease];
        _messagesHolderView.dataSource = self;
        _messagesHolderView.delegate = self;
        _messagesHolderView.backgroundColor = [UIColor clearColor];
        _messagesHolderView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_messagesHolderView];
        
        _expressionManager = [ExpressionManager defaultManager];
        self.messages = [[DiceChatMsgManager defaultManager] messages];
        
        [self addExpressions];
    }
    
    return self;
}

- (void)addExpressions
{
    int expsCount = [[_expressionManager allKeys] count];
    int pageCount = expsCount / 5 + (expsCount % 5 == 0 ? 0 : 1);
    
    CGRect frame;
    for (int i = 0; i < pageCount; i ++) {
        frame = CGRectMake(WIDTH_EXPRESSION_HOLDER_VIEW * i, 0, WIDTH_EXPRESSION_HOLDER_VIEW, HEIGHT_EXPRESSION_HOLDER_VIEW);
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
    for (int i = start; i < end; i++)
    {
        frame = CGRectMake((WIDTH_EXPRESSION_VIEW + EDGE_BETWEEN_EXPRESSIONS) * (i % EXPRESSION_COUNT_PER_PAGE), 0, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);
        UIButton *expression = [self expressionWithFrame:frame key:[allKeys objectAtIndex:i]];
        [view addSubview:expression];
    }
}


- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection
{
    [self dismissAnimated:YES];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    _popTipView.backgroundColor = POPTIPVIEW_BG_COLOR;
    _popTipView.disableTapToDismiss = YES;
    
    [_popTipView presentPointingAtView:view 
                                inView:inView
                              animated:animated
                        pointDirection:pointDirection];
}

- (CMPopTipView *)popTipView
{
    return _popTipView;
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
        [button setBackgroundImage:[[DiceImageManager defaultManager] diceExpressionBgImage] forState:UIControlStateNormal];
        
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
//    UIImage *image = [button imageForState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(didClickExepression:)]) {
        [_delegate didClickExepression:key];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewCell *cell = (ChatViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatViewCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [ChatViewCell createCell:self];
    }
    
    [cell setCellData:[_messages objectAtIndex:indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatViewCell getCellHeight];
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth +1);
    _pageControl.currentPage = page;
}

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

@end
