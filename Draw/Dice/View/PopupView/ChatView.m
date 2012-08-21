//
//  ChatView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatView.h"
#import "ExpressionManager.h"

#define WIDTH_CHAT_VIEW 200
#define HEIGHT_CHAT_VIEW 100
#define WIDTH_EXPRESSION_VIEW 20
#define HEIGHT_EXPRESSION_VIEW 20

@interface ChatView()
{
    ExpressionManager *_expressionManager;
}

@property (retain, nonatomic) UIScrollView *expressionsHolderView;
@property (retain, nonatomic) UITableView *messagesHolderView;
@property (retain, nonatomic) NSArray *messages;

@end



@implementation ChatView

@synthesize delegate = _delegate;
@synthesize expressionsHolderView = _expressionsHolderView;
@synthesize messagesHolderView = _messagesHolderView;
@synthesize messages = _messages;

- (void)dealloc
{
    [_expressionsHolderView release];
    [_messagesHolderView release];
    [_messages release];
    [super dealloc];
}

- (id)init
{
    CGRect frame = CGRectMake(0, 0, WIDTH_CHAT_VIEW, HEIGHT_CHAT_VIEW);
    if (self = [super initWithFrame:frame]) {
        _expressionManager = [ExpressionManager defaultManager];
        
        UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
        int i = 0;
        CGRect frame;
        for (NSString *key in [_expressionManager allKeys]) {
            frame = CGRectMake(WIDTH_EXPRESSION_VIEW * i, 0, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);
            UIButton *expression = [self expressionWithFrame:frame key:key];
            [view addSubview:expression];
        }
        
        [self.expressionsHolderView addSubview:view];
    
        
        self.messagesHolderView.dataSource = self;
        self.messagesHolderView.delegate = self;

    }
    
    return self;
}


- (UIButton *)expressionWithFrame:(CGRect)frame
                        key:(NSString *)key
{
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [button setImage:[_expressionManager expressionForKey:key] forState:UIControlStateNormal];
    [button setTitle:key forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickExpression:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)clickExpression:(id)sender
{
    UIButton *button = (UIButton *)sender;
//    NSString *key = [button titleForState:UIControlStateNormal];
    UIImage *image = [button imageForState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(didClickExepression:)]) {
        [_delegate didClickExepression:image];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end
