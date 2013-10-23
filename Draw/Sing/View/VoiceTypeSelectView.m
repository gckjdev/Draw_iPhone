//
//  VoiceTypeSelectView.m
//  Draw
//
//  Created by 王 小涛 on 13-10-15.
//
//

#import "VoiceTypeSelectView.h"
#import "SingOpus.h"
#import "AutoCreateViewByXib.h"

@implementation VoiceTypeSelectView

AUTO_CREATE_VIEW_BY_XIB(VoiceTypeSelectView);

+ (id)createWithVoiceType:(PBVoiceType)voiceType{
    
    VoiceTypeSelectView *v = [self createView];
    
    v.backgroundColor = [UIColor whiteColor];
    
    [v enumSubviewsWithClass:[UIButton class] handler:^(UIButton *button) {
        SET_BUTTON_ROUND_STYLE_YELLOW(button);
        
        if (button.tag == PBVoiceTypeVoiceTypeOrigin) {
            [button setTitle:NSLS(@"kVoiceTypeOrigin") forState:UIControlStateNormal];
        }else if (button.tag == PBVoiceTypeVoiceTypeTomCat){
            [button setTitle:NSLS(@"kVoiceTypeTomCat") forState:UIControlStateNormal];
        }else if (button.tag == PBVoiceTypeVoiceTypeMale){
            [button setTitle:NSLS(@"kVoiceTypeMale") forState:UIControlStateNormal];
        }else if (button.tag == PBVoiceTypeVoiceTypeFemale){
            [button setTitle:NSLS(@"kVoiceTypeFemale") forState:UIControlStateNormal];
        }else{
            [button setTitle:NSLS(@"kUnkown") forState:UIControlStateNormal];
        }
        
        [button addTarget:v action:@selector(clickVoiceTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [v setVoiceType:voiceType];
    
    return v;
}

- (void)setVoiceType:(PBVoiceType)voiceType{
    
    [self enumSubviewsWithClass:[UIButton class] handler:^(UIButton *button) {
        
        button.selected = NO;
        if (button.tag == voiceType) {
            button.selected = YES;
        }
    }];
}

//- (PBVoiceType)getVoiceType{
//    
//    __block PBVoiceType voiceType;
//    
//    [self enumSubviewsWithClass:[UIButton class] handler:^(UIButton *button) {
//        
//        if (button.selected == YES) {
//            voiceType = button.tag;
//        }
//    }];
//    
//    return voiceType;
//}

- (void)clickVoiceTypeButton:(UIButton *)button{
    
    [self enumSubviewsWithClass:[UIButton class] handler:^(UIButton *btn) {
       
        btn.selected = NO;
    }];
    
    button.selected = YES;
    
    if ([_delegate respondsToSelector:@selector(didSelectVoiceType:)]) {
        [_delegate didSelectVoiceType:button.tag];
    }
}

@end
