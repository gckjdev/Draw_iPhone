//
//  PickToolView.m
//  Draw
//
//  Created by  on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickToolView.h"
#import "StableView.h"
#import "ItemManager.h"
#import "ShareImageManager.h"
#import "UIButtonExt.h"
#import "Item.h"

#define PICK_TOOL_VIEW_WIDTH ([DeviceDetection isIPAD] ? 138  : 69)

#define TITLE_LABEL_FRAME ([DeviceDetection isIPAD] ? CGRectMake(0, 10 * 2, PICK_TOOL_VIEW_WIDTH, 35 * 2) : CGRectMake(0, 10, PICK_TOOL_VIEW_WIDTH, 35))

#define PICK_TOOLVIEW_FRAME ([DeviceDetection isIPAD] ? CGRectMake(613, 273, PICK_TOOL_VIEW_WIDTH, 427) : CGRectMake(250, 100, PICK_TOOL_VIEW_WIDTH, 214))

#define TOOL_X ([DeviceDetection isIPAD] ? 8 : 4)

#define TITLE_FONT_SIZE ([DeviceDetection isIPAD] ? 18 * 2 : 18)

#define TOOL_DESC_FONT_SIZE ([DeviceDetection isIPAD] ? 14 * 2 : 14)

#define TOOL_VIEW_HEIGHT ([DeviceDetection isIPAD] ? [ToolView height] + 20 * 2 : [ToolView height] + 20)

@interface PickToolView()
{
    NSMutableArray *_toolArray;
    UILabel *_title;
}

- (void)updateToolViews;
@property(nonatomic, retain) NSArray *tools;
@end


@implementation PickToolView
@synthesize tools = _toolArray;


- (id)initWithTools:(NSArray *)tools
{
    self = [super initWithFrame:PICK_TOOLVIEW_FRAME];
    if (self) {
//        _title = [[UILabel alloc] initWithFrame:TITLE_LABEL_FRAME];
//        [self addSubview:_title];
//        [_title setBackgroundColor:[UIColor clearColor]];
//        [_title setFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
//        [_title setText:NSLS(@"kPickToolTitle")];
//        [_title setTextAlignment:UITextAlignmentCenter];
        [self setImage:[[ShareImageManager defaultManager] pickToolBackground]];
        self.tools = tools;
        [self updateToolViews];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_toolArray);
    PPRelease(_title);
    [super dealloc];
}

- (void)clickToolView:(ToolView *)toolView
{
    if (_delegate && [_delegate respondsToSelector:@selector(didPickedPickView:toolView:)]) {
        [_delegate didPickedPickView:self toolView:toolView];
    }
    [self setHidden:YES animated:YES];
}

//- (void)sortTools
//{
//    [_toolArray sortUsingComparator:^(id obj1,id obj2){
//        return NSOrderedAscending;
//        ToolView *tool1 = (ToolView *)obj1;
//        ToolView *tool2 = (ToolView *)obj2;
//        NSInteger toolCount1 = [[ItemManager defaultManager] amountForItem:tool1.itemType];
//        NSInteger toolCount2 = [[ItemManager defaultManager] amountForItem:tool2.itemType];
//        NSInteger ret = toolCount2 - toolCount1;
//        if (ret == 0) {
//            return NSOrderedSame;
//        }else if(ret < 0)
//        {
//            return NSOrderedDescending;
//        }else{
//            return NSOrderedDescending;
//        }
//    }];
//    
//}

- (void)updateToolViews
{
    NSInteger count = [_toolArray count];
    if (count == 0) {
        return;
    }
//    [self sortTools];
    CGFloat height = self.frame.size.height;
    CGFloat ySpace = (height - [ToolView height] * count)/ (count + 1);
    CGFloat y = ySpace;
    for (int i = 0; i < count; ++ i) {
        ToolView *tool = [_toolArray objectAtIndex:i];
        tool.frame = CGRectMake(TOOL_X, y, [ToolView width], [ToolView height] + 20);
//        [tool setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [tool.titleLabel setFont:[UIFont systemFontOfSize:TOOL_DESC_FONT_SIZE]];
//        [tool setTitle:[Item actionNameForItemType:tool.itemType] forState:UIControlStateNormal];
//        [tool centerImageAndTitle:-1];
        [tool addTarget:self action:@selector(clickToolView:)];
        [self addSubview:tool];
        y += ySpace + [ToolView height];
    }
}

@end
