//
//  AddLearnDrawView.m
//  Draw
//
//  Created by gamy on 13-4-12.
//
//

#import "AddLearnDrawView.h"
#import "LearnDrawService.h"
#import "ShareImageManager.h"
#import "CustomInfoView.h"
#import "PPViewController.h"
#import "Draw.pb.h"

typedef enum{
    TabTypeCategory = 1,
    TabTypePrice = 2,
}TabType;

#define OFFSET 100

@interface AddLearnDrawView()
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *categoryLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) NSString *opusId;

@end

@implementation AddLearnDrawView

#define BUTTON_DEFAULT_COLOR [UIColor colorWithRed:62/255. green:42/255. blue:23/255. alpha:1]
#define BUTTON_SELETED_COLOR [UIColor whiteColor]
#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:26] : [UIFont boldSystemFontOfSize:14])


+ (id)createViewWithOpusId:(NSString *)opusId
{
    AddLearnDrawView *view = [UIView createViewWithXibIdentifier:@"AddLearnDrawView"];
    view.opusId = opusId;
    [view updateTabButtons:TabTypePrice];
    [view updateTabButtons:TabTypeCategory];
    return view;
}


- (UIButton *)currentButtonForTabType:(TabType)type
{
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]] && [button isSelected]) {
            if ([self button:button isType:type]) {
                return button;
            }
        }
    }
    return nil;
}

- (void)selectButton:(UIButton *)button
{
    TabType type = TabTypeCategory;
    if ([self button:button isType:TabTypePrice]) {
        type = TabTypePrice;
    }
    [[self currentButtonForTabType:type] setSelected:NO];
    [button setSelected:YES];
}

- (UIButton *)buttonWithType:(TabType)type index:(NSInteger)index
{
    UIButton *button = (UIButton *)[self viewWithTag:[self tabIdForIndex:index type:type]];
    return button;
}

- (void)updateTabButtons:(TabType)type
{
    NSInteger index = 0;
    NSInteger count = [self tabCountForType:type];
    NSInteger start = 0;
    NSInteger end = count - 1;
    for(index = 0; index < count; ++ index){
        UIButton *button = [self buttonWithType:type index:index];
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //title
        [button setTitle:[self tabTitleforIndex:index type:type] forState:UIControlStateNormal];
        
        //font
        [button.titleLabel setFont:BUTTON_FONT];
        
        [button setTitleColor:BUTTON_DEFAULT_COLOR forState:UIControlStateNormal];
        [button setTitleColor:BUTTON_SELETED_COLOR forState:UIControlStateSelected];
        //bg image
        if (index == start) {
            [button setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
        }else if(index == end){
            [button setBackgroundImage:[imageManager focusMeImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager focusMeSelectedImage] forState:UIControlStateSelected];
        }else{
            [button setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
        }
    }
    [self selectButton:[self buttonWithType:type index:0]];
}


- (NSInteger)tabCountForType:(TabType)type
{
    return 4;
}

- (BOOL)button:(UIButton *)button isType:(TabType)type 
{
    for (NSInteger i = 0; i < [self tabCountForType:type]; ++ i) {
        NSInteger tabID = [self tabIdForIndex:i type:type];
        if (button.tag == tabID) {
            return YES;
        }
    }
    return NO;
}

- (int)tabIdForIndex:(int)index type:(TabType)type
{
    if (type == TabTypeCategory) {
        int types[] = {
            //        LearnDrawTypeAll,
            LearnDrawTypeCartoon,
            LearnDrawTypeCharater,
            LearnDrawTypeScenery,
            LearnDrawTypeOther};
        
        return types[index];
    }
    if (type == TabTypePrice) {
        int types[] = {101, 102, 103, 105};
        return types[index];
    }
    return -1;
    
}

- (NSString *)tabTitleforIndex:(NSInteger)index type:(TabType)type
{
    if (type == TabTypeCategory) {
        NSString *titles[] =   {
            NSLS(@"kLearnDrawCartoon"),
            NSLS(@"kLearnDrawCharater"),
            NSLS(@"kLearnDrawScenery"),
            NSLS(@"kLearnDrawOther")};
        return titles[index];
    }
    if (type == TabTypePrice) {
        NSInteger tabID = [self tabIdForIndex:index type:type];
        NSInteger value = tabID - OFFSET;
        return [NSString stringWithFormat:@"%d", value];
    }
    return nil;
}


- (NSInteger)price
{
    return [self currentButtonForTabType:TabTypePrice].tag - OFFSET;
}
- (NSInteger)type
{
    return [self currentButtonForTabType:TabTypeCategory].tag;
}

- (void)selectButtonWithTag:(NSInteger)tag
{
    UIButton *button = (id)[self viewWithTag:tag];
    if ([button isKindOfClass:[UIButton class]]) {
        [self selectButton:button];
    }
}

- (void)setPrice:(NSInteger)price
{
    NSInteger tabID = price + OFFSET;
    [self selectButtonWithTag:tabID];
}
- (void)setType:(LearnDrawType)type
{
    [self selectButtonWithTag:type];
}


- (void)updateLearnDrawWithPrice:(NSInteger)price type:(LearnDrawType)type
{
    if (self.feed) {
        PBLearnDraw_Builder *builder = nil;
        if (self.feed.learnDraw) {
            builder = [PBLearnDraw builderWithPrototype:self.feed.learnDraw];
            [builder setOpusId:self.feed.feedId];
            [builder setPrice:price];
            [builder setType:type];
            self.feed.learnDraw = [builder build];
            
            UIViewController *vc = [self theViewController];
            if ([vc respondsToSelector:@selector(reloadTableView)]) {
                [vc performSelector:@selector(reloadTableView)];
            }
        }
    }
}

- (void)showInView:(UIView *)view
{
    CustomInfoView *customInfoView = [CustomInfoView createWithTitle:NSLS(@"kAddLearnDraw")
                                                            infoView:self
                                                      hasCloseButton:NO
                                                        buttonTitles:[NSArray arrayWithObjects:NSLS(@"kCancel"), NSLS(@"kOK"), nil]];
    
    [customInfoView showInView:view];
                                      
    [customInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        NSString *title = [button titleForState:UIControlStateNormal];
        if ([title isEqualToString:NSLS(@"kCancel")]) {
            [customInfoView dismiss];
            customInfoView.infoView = nil;
            [customInfoView setActionBlock:nil];
        }else if([title isEqualToString:NSLS(@"kOK")]){
            
            AddLearnDrawView *ldView = (AddLearnDrawView *)infoView;
            
            PPViewController *vc = (PPViewController *)[ldView theViewController];
            [vc showActivityWithText:NSLS(@"kAdding")];
            [[LearnDrawService defaultManager] addOpusToLearnDrawPool:ldView.opusId
                                                                price:ldView.price
                                                                 type:ldView.type
                                                        resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
                                                            [vc hideActivity];
                                                            if (resultCode == 0) {
                                                                [customInfoView dismiss];
                                                                customInfoView.infoView = nil;
                                                                [customInfoView setActionBlock:nil];
                                                                [ldView updateLearnDrawWithPrice:ldView.price type:ldView.type];
                                                            }else{
                                                                [vc popupHappyMessage:NSLS(@"kFailAdd") title:nil];
                                                            }

            }];
            
        }
    }];
     
}
- (void)dismiss
{
    
}


- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    PPRelease(_categoryLabel);
    PPRelease(_priceLabel);
    PPRelease(_feed);
    [super dealloc];
}
@end
