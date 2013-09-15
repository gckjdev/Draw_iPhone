//
//  CommentHeaderView.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentHeaderView.h"
#import "PPViewController.h"
#import "UIViewUtils.h"

@implementation CommentHeaderView
@synthesize delegate = _delegate;
@synthesize feed = _feed;

- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    PPRelease(_feed);
    [super dealloc];
}

+ (CommentType *)getTypeCountByFeed:(DrawFeed *)feed
{
    CommentType *types = [self getTypeListByFeed:feed];
    int i = 0;
    for (; types[i] != CommentTypeNO; ++ i);
    return i;
}

+ (CommentType *)getTypeListByFeed:(DrawFeed *)feed {
    if([feed isContestFeed]){
        static CommentType contestFeedTypes[] = {CommentTypeComment, CommentTypeFlower, CommentTypeContestComment,CommentTypeSave,CommentTypeNO};
        return contestFeedTypes;
    }else{
        static CommentType normalFeedTypes[] = {CommentTypeComment, CommentTypeGuess, CommentTypeFlower, CommentTypeSave, CommentTypeNO};
        return normalFeedTypes;        
    }
}
#define KEY(x) @(x)

- (NSString *)formatForType:(CommentType)type
{
    NSDictionary *dict =
    @{
      KEY(CommentTypeComment) : NSLS(@"kCommentTimes"),
      KEY(CommentTypeGuess) : NSLS(@"kGuessTimes"),
      KEY(CommentTypeFlower) : NSLS(@"kFlowerTimes"),
      KEY(CommentTypeSave) : NSLS(@"kCollectTimes"),
      KEY(CommentTypeContestComment) : NSLS(@"kReportTimes")};    
    return [dict objectForKey:KEY(type)];
    
}

- (NSInteger)countForType:(CommentType)type
{
    NSDictionary *dict =
    @{
      KEY(CommentTypeComment) : @(self.feed.commentTimes),
      KEY(CommentTypeGuess) : @(self.feed.guessTimes),
      KEY(CommentTypeFlower) : @(self.feed.flowerTimes),
      KEY(CommentTypeSave) : @(self.feed.saveTimes),
      KEY(CommentTypeContestComment) : @(self.feed.contestCommentTimes)};
    NSInteger v = [[dict objectForKey:KEY(type)] integerValue];
    return MAX(v, 0);
}

- (void)enumCommentTypeWithBlock:(void (^)(CommentType commentType, NSInteger index))handler{
    CommentType *types = [CommentHeaderView getTypeListByFeed:self.feed];
    NSInteger currentIndex = 0;
    for (CommentType *type = types; type != NULL && (*type) != CommentTypeNO; type++) {
        if(handler){
            handler(*type, currentIndex ++);
        }
    }
}


- (NSInteger)indexForCommentType:(CommentType)type
{
    __block NSInteger idx = NSNotFound;
    [self enumCommentTypeWithBlock:^(CommentType commentType, NSInteger index) {
        if (commentType == type) {
            idx = index;
            return;
        }
    }];
    return idx;
}

- (NSInteger)commentTypeForIndex:(NSInteger)idx{

    __block CommentType type = CommentTypeNO;
    [self enumCommentTypeWithBlock:^(CommentType commentType, NSInteger index) {
        if (idx == index) {
            type = commentType;
            return;
        }
    }];
    return type;
}

#define SPLIT_TAG_PLUS 10000
#define TAB_HEIGHT (ISIPAD ? 75 : 37)
#define TAB_WIDTH (ISIPAD ? 713 : 299)
#define BUTTON_HEIGHT (ISIPAD ? 50 : 25) 
#define START_X ([DeviceDetection isIPAD] ? 8 : 4)
#define TAB_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:25] : [UIFont systemFontOfSize:11])

- (NSInteger)splitLineTagWithType:(CommentType)type
{
    NSInteger tag = type + SPLIT_TAG_PLUS;
    return tag;
}

- (UIButton *)buttonWithType:(CommentType)type
{
    if ([self indexForCommentType:type] != NSNotFound) {
        UIButton *b = (UIButton *)[self viewWithTag:type];
        return b;
    }
    return nil;
}


- (IBAction)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self setSelectedType:button.tag];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SET_VIEW_BG(self);
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        UIColor *color = [UIColor colorWithPatternImage:[[ShareImageManager defaultManager] detailHeaderBG]];
        [self addSubview:view];        
        [view setBackgroundColor:color];
        [view release];
    }
    return self;
}

+ (id)createCommentHeaderView:(id)delegate
{
    CGRect frame = CGRectMake(0, 0, TAB_WIDTH, TAB_HEIGHT);
    CommentHeaderView *headerView = [[[CommentHeaderView alloc] initWithFrame:frame] autorelease];
    headerView.delegate = delegate;
    return headerView;
}
- (void)setSelectedType:(CommentType)type
{
    if (_currentType == type) {
        return;
    }
    
    if (type == CommentTypeSave) {
        POSTMSG(NSLS(@"kNoSaveList"));
        return;
    }
    UIButton *button = [self buttonWithType:type];
    UIButton *b1 = [self buttonWithType:_currentType];
    [b1 setSelected:NO];
    [button setSelected:YES];
    _currentType = type;

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCommentType:)]) {
        [self.delegate didSelectCommentType:_currentType];
    }
}
- (CommentType)selectedType
{
    return _currentType;
}


- (void)updateButtonWithType:(CommentType)type 
                       times:(NSInteger)times 
                      format:(NSString *)format
{
    NSString *title = [NSString stringWithFormat:format,times];
    [self reuseButtonWithTag:type frame:CGRectMake(0, TAB_HEIGHT-BUTTON_HEIGHT, 1, BUTTON_HEIGHT) font:TAB_FONT text:title];
}
- (void)setViewInfo:(DrawFeed *)feed
{
    self.feed = feed;
    [self updateTimes:feed];
}

+ (CGFloat)getHeight
{
    return TAB_HEIGHT;
}

#define SPACE (ISIPAD ? 12 : 5)
#define SPLIT_WIDTH (ISIPAD ? 2 : 1)
#define SPLIT_HEIGHT (BUTTON_HEIGHT*0.5)


- (void)updateTimes:(DrawFeed *)feed
{
    [self enumCommentTypeWithBlock:^(CommentType commentType, NSInteger index) {
        CGFloat x = START_X;
        if (index > 0) {
            //set split line
            NSInteger tag = [self splitLineTagWithType:commentType];
            CommentType prevType = [self commentTypeForIndex:index - 1];
            UIButton *btn = [self buttonWithType:prevType];
            CGFloat y = TAB_HEIGHT - BUTTON_HEIGHT - SPLIT_HEIGHT/2;
            CGRect frame = CGRectMake(CGRectGetMaxX(btn.frame) + SPACE, y, 1, SPLIT_HEIGHT);
            UIView *split = [self reuseViewWithTag:tag viewClass:[UIView class] frame:frame];
            [split setBackgroundColor:COLOR_GRAY_TEXT]; //[UIColor grayColor]];
            x = CGRectGetMaxX(split.frame) + SPACE;
            [split updateCenterY:btn.center.y];
        }

        NSInteger count = [self countForType:commentType];
        NSString *format = [self formatForType:commentType];
        [self updateButtonWithType:commentType times:count format:format];
        UIButton *btn = [self buttonWithType:commentType];
//        btn.alpha = 0.4;
        [btn updateOriginX:x];
        [btn updateHeight:BUTTON_HEIGHT];
        if (!_hasCreateButton) {
            [btn setTitleColor:COLOR_GRAY_TEXT forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_BROWN forState:UIControlStateSelected];
//            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        }

    }];
    _hasCreateButton = YES;
    
}

@end
