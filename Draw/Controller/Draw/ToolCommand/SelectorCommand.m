//
//  SelectorCommand.m
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import "SelectorCommand.h"
#import "CommonMessageCenter.h"
#import "CustomInfoView.h"

#define VALUE(X) (ISIPAD ? 2*X : X)
#define WIDTH ([LocaleUtils isChinese] ? VALUE(180) : VALUE(230))
#define HEIGHT VALUE(200)
#define FONT_SIZE VALUE(16)

@interface SelectorCommand()

@property(nonatomic, retain)SelectorBox *box;

@end

@implementation SelectorCommand


- (void)dealloc
{
    PPRelease(_box);
    [super dealloc];
}

- (UIView *)contentView
{
    if (self.box == nil) {
        self.box = [SelectorBox selectorBoxWithDelegate:self];
    }
    return self.box;
}

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
    }
    return YES;
}


- (TouchActionType)touchTypeFromClipType:(ClipType)cliptype
{
    NSDictionary *dict = @{@(ClipTypeEllipse): @(TouchActionTypeClipEllipse),
                           @(ClipTypeRectangle): @(TouchActionTypeClipRectangle),
                           @(ClipTypeSmoothPath): @(TouchActionTypeClipPath),
                           @(ClipTypePolygon): @(TouchActionTypeClipPolygon)
                           };
    return [[dict objectForKey:@(cliptype)] intValue];

}

- (void)selectorBox:(SelectorBox *)box didSelectClipType:(ClipType)clipType
{
    if (clipType != ClipTypeNo) {
        self.drawInfo.touchType = [self touchTypeFromClipType:clipType];
        [self.toolPanel updateWithDrawInfo:self.drawInfo];
    }
    [self hidePopTipView];
}
//- (void)didClickCancelAtSelectorBox:(SelectorBox *)box
//{
//    [self.drawView exitFromClipMode];
//    [self hidePopTipView];
//    [self.drawInfo backToLastDrawMode];
//    [self updateToolPanel];
//}
- (void)didClickHelpAtSelectorBox:(SelectorBox *)box
{
    [self hidePopTipView];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)] autorelease];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:OPAQUE_COLOR(62, 43, 23)];
    UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    [label setFont:font];
    [label setText:NSLS(@"kSelectorHelp")];
    CustomInfoView *info = [CustomInfoView createWithTitle:NSLS(@"kHelp") infoView:label];
    
    [info.mainView updateCenterY:(info.mainView.center.y - (ISIPAD ? 40 : 20))];
    
    [info showInView:[self.control theTopView]];

}

@end
