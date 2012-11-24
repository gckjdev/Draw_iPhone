//
//  FacetimeMainController.h
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacetimeService.h"
#import "PPViewController.h"
#import "MatchingFacetimeUserView.h"
#import "FacetimeUserInfoView.h"
#import "InputDialog.h"
#import "DiceAvatarView.h"
@class HKGirlFontLabel;
@class TestView;

@interface FacetimeMainController : PPViewController<FacetimeServiceDelegate,MatchingFacetimeUserViewDelegate,FacetimeUserInfoViewDelegate,InputDialogDelegate, DiceAvatarViewDelegate> {
    MatchingFacetimeUserView* _matchingFacetimeView;
    FacetimeUserInfoView* _facetimeUserInfoView;
    int _requestType;
}
@property (retain, nonatomic) IBOutlet DiceAvatarView *testDiceAvatar;
@property (retain, nonatomic) IBOutlet TestView* test;

@end
