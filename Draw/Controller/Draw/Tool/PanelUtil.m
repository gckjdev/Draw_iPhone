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
      
      
      KEY(DrawToolTypeUndo): @"draw_undo_normal@2x.png",
      KEY(DrawToolTypeRedo): @"draw_redo_normal@2x.png",

      KEY(DrawToolTypeShadow): @"draw_shadow@2x.png",
      KEY(DrawToolTypeGradient): @"draw_gradient@2x.png",
      KEY(DrawToolTypeBucket): @"draw_oil@2x.png",
      KEY(DrawToolTypeText): @"draw_text@2x.png",
      KEY(DrawToolTypeFX) :@"draw_fx@2x.png",
      KEY(DrawToolTypeShape): @"draw_shape_image@2x.png",
      
      
      KEY(DrawToolTypeChat):@"group_message@2x.png",
      KEY(DrawToolTypeTimeset):@"timeset@2x.png",
      
      //for iphone 5
      KEY(DrawToolTypePen):@"pen_pencil@2x.png",
      KEY(DrawToolTypeEraser):@"draw_rubber@2x.png",
      KEY(DrawToolTypePalette):@"draw_palette@2x.png",
      KEY(DrawToolTypeStraw):@"draw_straw@2x.png",
      KEY(DrawToolTypeAddColor):@"draw_add@2x.png",
      };

    NSString *name = [imageNameDict objectForKey:@(type)];
    return name ? IMAGE(name) : nil;
    
}

+ (UIImage *)bgImageForType:(DrawToolType)type state:(UIControlState)state
{
    NSDictionary *imageNameDict = nil;
    if(state == UIControlStateNormal){
        imageNameDict =
        @{
          KEY(DrawToolTypeBlock): @"draw_grid@2x.png",
          KEY(DrawToolTypeSelector): @"draw_selector@2x.png",
          KEY(DrawToolTypeShape): @"draw_shape_default@2x.png",
          KEY(DrawToolTypeCanvaseBG): @"draw_canvas_bg@2x.png",
          };        
    }else if(state == UIControlStateSelected){
        imageNameDict =
        @{
          KEY(DrawToolTypeBlock): @"draw_grid_selected@2x.png",
          KEY(DrawToolTypeSelector): @"draw_selector_selected@2x.png",
          KEY(DrawToolTypeShape): @"draw_shape_selected@2x.png",
          KEY(DrawToolTypeCanvaseBG): @"draw_canvas_bg_selected@2x.png",
          };
    }
    
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
                                KEY(DrawToolTypeSubject): NSLS(@"kDefaultDrawWord"),
                                KEY(DrawToolTypePageBG) : NSLS(@"kChangePageBG")
                                };
    return [titleDict objectForKey:@(type)];
}

+ (DrawToolType *)belowToolList
{

    if (ISIPAD) {
        static int ipadList[] = {
            DrawToolTypeUndo,
            DrawToolTypeRedo,
            DrawToolTypeSelector,
            DrawToolTypeShadow,
            DrawToolTypeGradient,
            DrawToolTypeShape,
            DrawToolTypeBucket,
            DrawToolTypeCanvaseBG,
            DrawToolTypeBlock,
            DrawToolTypeEnd,
        };
        return ipadList;
    }else if(ISIPHONE5){
        
        static int ip5List[] = {
            
//            DrawToolTypePen,
//            DrawToolTypeEraser,
//            DrawToolTypePalette,
            DrawToolTypeShape,
            DrawToolTypeUndo,
            DrawToolTypeRedo,
            DrawToolTypeSelector,
            DrawToolTypeShadow,
            DrawToolTypeGradient,
            DrawToolTypeBucket,
            DrawToolTypeCanvaseBG,
            DrawToolTypeBlock,
            DrawToolTypeEnd,            
        };
        return ip5List;
    }else{
        static int ipList[] = {
            DrawToolTypeUndo,
            DrawToolTypeRedo,
            DrawToolTypeSelector,
            DrawToolTypeShadow,
            DrawToolTypeGradient,
            DrawToolTypeShape,
            DrawToolTypeBucket,
            DrawToolTypeBlock,
            DrawToolTypeEnd,
        };
        return ipList;
    }
}
+ (DrawToolType *)upToolList
{
    if (ISIPAD || ISIPHONE5) {
        static int ipadList[] = {
            DrawToolTypeSize,
            DrawToolTypeCopy,
            DrawToolTypeDesc,
            DrawToolTypeDrawTo,
            DrawToolTypePageBG,
            DrawToolTypeHelp,
            DrawToolTypeSubject,
            DrawToolTypeEnd,
        };
        return ipadList;
    }else{
        static int ipList[] = {
            DrawToolTypeSize,
            DrawToolTypeBG,
            DrawToolTypeCopy,
            DrawToolTypeDesc,
            DrawToolTypeDrawTo,
            DrawToolTypePageBG,            
            DrawToolTypeHelp,
            DrawToolTypeSubject,            
            DrawToolTypeEnd,
        };
        return ipList;
    }
}


+ (NSArray *)xsForTypes:(DrawToolType *)types
                   edge:(CGFloat)edge
                  width:(CGFloat)width
                  start:(CGFloat)start
                 length:(CGFloat)length
{
    NSUInteger number = [self numberOfTypeList:types];
    if (number > 1) {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:number];
        CGFloat space = (length - number * width- 2*edge)/(number+1);
        CGFloat step = width + space;
        CGFloat x = edge + width/2 + start;
        for (DrawToolType *type = types; type != NULL && (*type) != DrawToolTypeEnd; ++ type) {
            [list addObject:@(x)];
            x += step;
        }
        return list;
    }else{
        return [NSArray arrayWithObject:@(start + length/2)];
    }
}

+ (NSUInteger)numberOfTypeList:(DrawToolType *)types
{
    NSUInteger number = 0;
    for (DrawToolType *type = types; type != NULL && (*type) != DrawToolTypeEnd; ++ type) {
        number ++;
    }
    return number;
}

@end
