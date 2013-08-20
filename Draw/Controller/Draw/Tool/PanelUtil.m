//
//  DrawToolType.m
//  Draw
//
//  Created by gamy on 13-8-20.
//
//

#import "PanelUtil.h"

@implementation PanelUtil

#define IMAGE(x) [UIImage imageNamed:x]
#define KEY(x) (@(x))

+ (UIImage *)imageForType:(DrawToolType)type
{
    NSDictionary *imageNameDict =
    @{KEY(DrawToolTypeSize): @"draw_up_panel_canvas_btn@2x.png",
      KEY(DrawToolTypeBG): @"draw_up_panel_background@2x.png",
      KEY(DrawToolTypeCopy): @"draw_up_panel_copy_paint_btn@2x.png",
      KEY(DrawToolTypeDesc): @"draw_up_panel_edit_btn@2x.png",
      KEY(DrawToolTypeDrawTo): @"draw_up_panel_draw_to_btn@2x.png",
      KEY(DrawToolTypeGrid): @"draw_up_panel_blocks@2x.png",
      KEY(DrawToolTypeHelp): @"draw_up_panel_help_btn_@2x.png",
      };
    NSString *name = [imageNameDict objectForKey:@(type)];
    return name ? IMAGE(name) : nil;
    
}
+ (NSString *)titleForType:(DrawToolType)type
{
    NSDictionary *titleDict = @{KEY(DrawToolTypeSize): NSLS(@"kSize"),
                                KEY(DrawToolTypeBG): NSLS(@"kBackground"),
                                KEY(DrawToolTypeCopy): NSLS(@"kCopyPaint"),
                                KEY(DrawToolTypeDesc): NSLS(@"kDescription"),
                                KEY(DrawToolTypeDrawTo): NSLS(@"kDrawTo"),
                                KEY(DrawToolTypeGrid): NSLS(@"kGrid"),
                                KEY(DrawToolTypeHelp): NSLS(@"kScaleHelp"),
                                KEY(DrawToolTypeSubject): NSLS(@"kDefaultDrawWord")
                                };
    return [titleDict objectForKey:@(type)];
}

@end
