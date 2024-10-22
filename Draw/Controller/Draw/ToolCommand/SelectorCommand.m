//
//  SelectorCommand.m
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import "SelectorCommand.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"

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

- (void)didClickHelpAtSelectorBox:(SelectorBox *)box
{
    [self hidePopTipView];
    
    [[CommonDialog createDialogWithTitle:NSLS(@"kHelp") message:NSLS(@"kSelectorHelp") style:CommonDialogStyleCross] showInView:[self.controller view]];
}

@end
