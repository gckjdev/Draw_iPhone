//
//  DiceImageManager.m
//  Draw
//
//  Created by 小涛 王 on 12-7-28.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceImageManager.h"
#import "UIImageUtil.h"
#import "HKGirlFontLabel.h"
#import "LocaleUtils.h"

static DiceImageManager *_defaultManager = nil;

@implementation DiceImageManager

+ (DiceImageManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceImageManager alloc] init];
    }
    
    return _defaultManager;
}

- (UIImage *)roomListBgImage
{
    return [UIImage imageNamed:@"dice_room_background.png"];
}

- (UIImage *)createRoomBtnBgImage
{
    return [UIImage strectchableImageName:@"dice_play.png" leftCapWidth:15 topCapHeight:15];
}

- (UIImage *)fastGameBtnBgImage
{
    return [UIImage strectchableImageName:@"dice_create_room.png" leftCapWidth:15 topCapHeight:15];
}

- (UIImage *)graySafaImage
{
    return [UIImage strectchableImageName:@"dice_gray_safa@2x.png"];
}

- (UIImage *)greenSafaImage
{
    return [UIImage strectchableImageName:@"dice_green_safa@2x.png"];
}

- (UIImage *)blueSafaImage
{
    return [UIImage strectchableImageName:@"dice_blue_safa@2x.png"];
}

- (UIImage *)diceImageWithDice:(int)dice
{
    UIImage *image = nil;
    
    switch (dice) {
        case 1:
            image = [UIImage imageNamed:@"bell_1@2x.png"];
            break;
            
        case 2:
            image = [UIImage imageNamed:@"bell_2@2x.png"];
            break;
            
        case 3:
            image = [UIImage imageNamed:@"bell_3@2x.png"];
            break;
            
        case 4:
            image = [UIImage imageNamed:@"bell_4@2x.png"];
            break;
            
        case 5:
            image = [UIImage imageNamed:@"bell_5@2x.png"];
            break;
            
        case 6:
            image = [UIImage imageNamed:@"bell_6@2x.png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

- (UIImage *)openDiceImageWithDice:(int)dice 
{
    UIImage *image = nil;
    
    switch (dice) {
        case 1:
            image = [UIImage imageNamed:@"open_bell_1bigx2.png"];
            break;
            
        case 2:
            image = [UIImage imageNamed:@"open_bell_2bigx2.png"];
            break;
            
        case 3:
            image = [UIImage imageNamed:@"open_bell_3bigx2.png"];
            break;
            
        case 4:
            image = [UIImage imageNamed:@"open_bell_4bigx2.png"];
            break;
            
        case 5:
            image = [UIImage imageNamed:@"open_bell_5bigx2.png"];
            break;
            
        case 6:
            image = [UIImage imageNamed:@"open_bell_6bigx2.png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

- (UIImage*)customDiceImageWithDiceName:(NSString*)name 
                                   dice:(int)dice
{
    if (name == nil || [name isEqualToString:@""]) {
        return [self diceImageWithDice:dice];
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"dice_%@_%d.png", name, dice]];
}

- (UIImage*)customOpenDiceImageWithDiceName:(NSString*)name 
                                       dice:(int)dice
{
    if (name == nil || [name isEqualToString:@""]) {
        return [self openDiceImageWithDice:dice];
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"openDice_%@_%d.png", name, dice]];
}

- (UIImage *)toolBackgroundImage
{
    return [UIImage strectchableImageName:@"tools_bg.png" leftCapWidth:14 topCapHeight:14];    
}

- (UIImage *)toolEnableCountBackground
{
    return [UIImage imageNamed:@"tools_enable.png"];
}

- (UIImage *)toolDisableCountBackground
{
    return [UIImage imageNamed:@"tools_disable.png"];
}

- (UIImage *)diceCountBtnBgImage
{
    return [UIImage imageNamed:@"bell_amount@2x.png"];
}

- (UIImage *)diceCountSelectedBtnBgImage
{
    return [UIImage imageNamed:@"bell_amount_selected@2x.png"];

}

- (UIImage *)diceSeletedBgImage
{
    return [UIImage imageNamed:@"bell_selectedbg.png"];
}

- (UIImage *)diceBottomImage
{
    return [UIImage imageNamed:@"dice_bottombig.png"];
}

- (UIImage *)wildsBgImage
{
    return [UIImage imageNamed:@"zhai_bg.png"];
}

- (UIImage *)openDiceButtonBgImage
{
    return [UIImage strectchableImageName:@"open.png" leftCapWidth:15 topCapHeight:15];
}

- (UIImage *)whiteSofaImage
{
    return [UIImage imageNamed:@"waiting_user.png"];
}

- (UIImage *)resultDiceBgImage
{
    return [UIImage imageNamed:@"open_bell_counton.png"];
}

- (UIImage *)roomCellBackgroundImage
{
    return [UIImage strectchableImageName:@"dice_room_item.png"];
}

- (UIImage *)toolsItemBgImage
{
    return [UIImage imageNamed:@"tools_bell_bg.png"];
}

- (UIImage *)closeButtonBackgroundImage
{
    return [UIImage imageNamed:@"dice_close_btn.png"];
}
- (UIImage *)faceBackgroundImage
{
    return [UIImage imageNamed:@"dice_face_bg.png"];
}
- (UIImage *)helpBackgroundImage
{
    return [UIImage strectchableImageName:@"dice_help_bg.png" leftCapWidth:50 topCapHeight:50];
}
- (UIImage *)inputBackgroundImage
{
    return [UIImage strectchableImageName:@"dice_input_bg.png"];
}
- (UIImage *)messageTipBackgroundImage
{
    return [UIImage imageNamed:@"dice_input_bg.png"];
}
- (UIImage *)popupBackgroundImage
{
    return [UIImage strectchableImageName:@"dice_popup_bg.png"];
}
- (UIImage *)diceQuitBtnImage
{
    return [UIImage strectchableImageName:@"dice_quit_btn.png"  leftCapWidth:15 topCapHeight:15];
}

- (UIImage *)diceChatMsgBgImage
{
    return [UIImage strectchableImageName:@"dice_message_tip.png" leftCapWidth:10];
}

- (UIImage *)diceExpressionBgImage
{
    return [UIImage imageNamed:@"dice_face_bg.png"];
}

- (UIImage *)diceMusicOnImage
{
    return [UIImage imageNamed:@"music_on.png"];
}

- (UIImage *)diceMusicOffImage
{
    return [UIImage imageNamed:@"music_off.png"];
}

- (UIImage *)diceAudioOnImage
{
    return [UIImage imageNamed:@"audio_on.png"];
}

- (UIImage *)diceAudioOffImage
{
    return [UIImage imageNamed:@"audio_off.png"];
}
- (UIImage *)maleImage
{
    return [UIImage imageNamed:@"maleImage.png"];
}
- (UIImage *)femaleImage
{
    return [UIImage imageNamed:@"femaleImage.png"];
}

- (UIImage *)diceToolCutImage
{
    UIImage* backgroundImage = [UIImage imageNamed:@"tools_bell_bg@2x.png"];
    float width = backgroundImage.size.width;
    float height = backgroundImage.size.height;
    HKGirlFontLabel* label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(width*0.2, 
                                                                                width*0.1, 
                                                                                width*0.6, 
                                                                                height*0.6) 
                                                           pointSize:80]
                              autorelease];
    
    [label setText:NSLS(@"kToolCut")];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    
    return [UIImage creatImageByImage:backgroundImage withLabel:label];
}

- (UIImage *)diceToolRollAgainImage
{
    UIImage* backgroundImage = [UIImage imageNamed:@"tools_bell_bg@2x.png"];
    float width = backgroundImage.size.width;
    float height = backgroundImage.size.height;
    HKGirlFontLabel* label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(width*0.2, 
                                                                                width*0.1, 
                                                                                width*0.6, 
                                                                                height*0.6) 
                                                           pointSize:80] //here just need a big big pointsize
                              autorelease];
    

    [label setText:NSLS(@"kToolRollAgain")];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];

    return [UIImage creatImageByImage:backgroundImage withLabel:label];
}

- (UIImage *)diceToolCutImageForShop
{
    return [UIImage shrinkImage:[self diceToolCutImage] withRate:0.8];
}

- (UIImage *)diceToolRollAgainImageForShop
{
    return [UIImage shrinkImage:[self diceToolRollAgainImage] withRate:0.8];
}

- (UIImage *)peekImage
{
    return [UIImage imageNamed:@"eye@2x.png"];
}

- (UIImage *)postponeImage
{
    return [UIImage imageNamed:@"delay@2x.png"];

}
- (UIImage *)urgeImage
{
    return [UIImage imageNamed:@"hurryup@2x.png"];
}

- (UIImage *)doubleKillImage
{
    return nil;
}

- (UIImage *)turtleImage
{
    return [UIImage imageNamed:@"tortoise@2x.png"];
}

- (UIImage *)reverseImage
{
    return [UIImage imageNamed:@"reverse@2x.png"];
}

- (UIImage *)diceRobotImage
{
    return [UIImage imageNamed:@"diceRobot@2x.png"];
}

- (UIImage*)patriotDiceImage
{
    return [UIImage imageNamed:@"openDice_ag_1.png"];
}

- (UIImage*)goldenDiceImage
{
    return [UIImage imageNamed:@"openDice_golden_1.png"];
}


- (UIImage*)woodDiceImage
{
    return [UIImage imageNamed:@"openDice_wood_1.png"];
}


- (UIImage*)blueCrystalDiceImage
{
    return [UIImage imageNamed:@"openDice_blueCrystal_1.png"];
}


- (UIImage*)pinkCrystalDiceImage
{
    return [UIImage imageNamed:@"openDice_pinkCrystal_1.png"];
}


- (UIImage*)greenCrystalDiceImage
{
    return [UIImage imageNamed:@"openDice_greenCrystal_1.png"];
}


- (UIImage*)purpleCrystalDiceImage
{
    return [UIImage imageNamed:@"openDice_purpleCrystal_1.png"];
}


- (UIImage*)blueDiamondDiceImage
{
    return [UIImage imageNamed:@"openDice_blueDiamond_1.png"];
}


- (UIImage*)pinkDiamondDiceImage
{
    return [UIImage imageNamed:@"openDice_pinkDiamond_1.png"];
}


- (UIImage*)greenDiamondDiceImage
{
    return [UIImage imageNamed:@"openDice_greenDiamond_1.png"];
}


- (UIImage*)purpleDiamondDiceImage
{
    return [UIImage imageNamed:@"openDice_purpleDiamond_1.png"];
}


- (UIImage*)toShopImage:(UIImage*)image
{
    return image;//[UIImage shrinkImage:image withRate:0.8];
}

- (UIImage *)betResultImage:(BOOL)win
{
    if (win) {
        return [UIImage imageNamed:@"win_face@2x.png"];
    }else {
        return [UIImage imageNamed:@"lose_face@2x.png"];
    }
}

@end
