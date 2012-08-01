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

@interface FacetimeMainController : PPViewController<FacetimeServiceDelegate,MatchingFacetimeUserViewDelegate,FacetimeUserInfoViewDelegate,InputDialogDelegate> {
    MatchingFacetimeUserView* _matchingFacetimeView;
    FacetimeUserInfoView* _facetimeUserInfoView;
    int _requestType;
}

@end
