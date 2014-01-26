//
//  PenBox.m
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import "PenBox.h"
#import "UserGameItemManager.h"
#import "Item.h"
#import "UIViewUtils.h"

#define BUTTON_SIZE (ISIPAD ? 96 : 48)

@interface PenBox()
{
    
}

- (IBAction)clickPen:(UIButton *)sender;

@end

@implementation PenBox

- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    [super dealloc];
}

- (UIButton *)buttonWithPenType:(ItemType)type
{
    UIImage *image = [Item imageForItemType:type];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[Item seletedPenImageForType:type] forState:UIControlStateSelected];
    [button setFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
    [button setImage:image forState:UIControlStateNormal];
    [button setTag:type];
    [button addTarget:self action:@selector(clickPen:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#define NUMBER_PER_ROW 5

- (void)updateView
{
    ItemType *list = [[UserGameItemManager defaultManager] boughtPenTypeList];
    NSInteger i = 0;

    while (list != NULL && *list != ItemTypeListEndFlag) {
        UIButton *button = [self buttonWithPenType:*list];
        [self addSubview:button];
        [button updateOriginX: ((i%NUMBER_PER_ROW) * BUTTON_SIZE)];
        [button updateOriginY: ((i/NUMBER_PER_ROW) * BUTTON_SIZE)];

        ++ i;
        ++ list;
    }
    [self updateWidth:(BUTTON_SIZE * MIN(i,NUMBER_PER_ROW))];
    NSInteger row = (i/NUMBER_PER_ROW) + !!(i%NUMBER_PER_ROW);
    [self updateHeight:row*BUTTON_SIZE];
}

+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"PenBox";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    PenBox  *view = (PenBox *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
}

- (IBAction)clickPen:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(penBox:didSelectPen:penImage:)]) {
        UIImage *image = [sender imageForState:UIControlStateNormal];
        [self.delegate penBox:self didSelectPen:sender.tag penImage:image];
    }
}
@end
