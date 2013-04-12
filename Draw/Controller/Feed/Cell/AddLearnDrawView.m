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

@interface AddLearnDrawView()
{
    
}
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property (retain, nonatomic) IBOutlet UILabel *categoryLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) NSString *opusId;

@end

@implementation AddLearnDrawView

#define BUTTON_DEFAULT_COLOR [UIColor colorWithRed:62/255. green:42/255. blue:23/255. alpha:1]
#define BUTTON_SELETED_COLOR [UIColor whiteColor]
#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:30] : [UIFont boldSystemFontOfSize:14])


+ (id)createViewWithOpusId:(NSString *)opusId
{
    AddLearnDrawView *view = [UIView createViewWithXibIdentifier:@"AddLearnDrawView"];
    view.opusId = opusId;
    return view;
}

- (UIButton *)currentSelectTabButton
{
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if ([button isSelected]) {
                return button;
            }
        }
    }
    return nil;
}

- (void)selectButtonWithTag:(NSInteger)tag
{
    [[self currentSelectTabButton] setSelected:NO];
    UIButton *button = (UIButton *)[self viewWithTag:[self tabIDforIndex:index]];
    [button setSelected:YES];
}

- (void)updateViews
{
    NSInteger index = 0;
    NSInteger count = [self tabCount];
    NSInteger start = 0;
    NSInteger end = count - 1;
    for(index = 0; index < count; ++ index){
        UIButton *button = (UIButton *)[self viewWithTag:[self tabIDforIndex:index]];
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        
        //title
        [button setTitle:[self tabTitleforIndex:index] forState:UIControlStateNormal];
        
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
    [self selectButtonWithTag:LearnDrawTypeCartoon];
    self.textField.text = @"1";
}


- (NSInteger)tabCount
{
    return 4;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    
    int types[] = {
//        LearnDrawTypeAll,
        LearnDrawTypeCartoon,
        LearnDrawTypeCharater,
        LearnDrawTypeScenery,
        LearnDrawTypeOther};
    
    return types[index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] =   {NSLS(@"kLearnDrawCartoon"),
                            NSLS(@"kLearnDrawCharater"),
                            NSLS(@"kLearnDrawScenery"),
                            NSLS(@"kLearnDrawOther")};
    return titles[index];
}

- (NSInteger)price
{
    return [[[self textField] text] integerValue];
}
- (NSInteger)type
{
    return [self currentSelectTabButton].tag;
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
    [_textField release];
    [_categoryLabel release];
    [_priceLabel release];
    [super dealloc];
}
@end
