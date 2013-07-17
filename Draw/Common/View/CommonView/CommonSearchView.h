//
//  CommonSearchView.h
//  Draw
//
//  Created by Orange on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonInfoView.h"

typedef enum {
    CommonSearchViewThemeDraw = 0,
    CommonSearchViewThemeDice = 1
}CommonSearchViewTheme;

@class CommonSearchView;

@protocol CommonSearchViewDelegate <NSObject>

- (void)willSearch:(NSString*)keywords 
            byView:(CommonSearchView*)view;

@end

@interface CommonSearchView : CommonInfoView <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;
@property (retain, nonatomic) IBOutlet UITextField *keywordInputField;
@property (assign, nonatomic) id<CommonSearchViewDelegate> delegate;


+ (CommonSearchView*)showInView:(UIView*)view 
           byTheme:(CommonSearchViewTheme)theme 
           atPoint:(CGPoint)point 
          delegate:(id<CommonSearchViewDelegate, CommonInfoViewDelegate>)delegate;

@end
