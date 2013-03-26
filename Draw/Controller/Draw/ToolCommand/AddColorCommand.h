//
//  AddColorCommand.h
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ToolCommand.h"
#import "ColorBox.h"
#import "ColorShopView.h"

@interface AddColorCommand : ToolCommand<ColorBoxDelegate, ColorShopViewDelegate>

@end
