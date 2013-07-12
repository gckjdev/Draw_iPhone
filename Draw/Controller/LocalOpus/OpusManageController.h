//
//  OpusManageController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTabController.h"
#import "PPViewController.h"
#import "ShareCell.h"
#import "CommonDialog.h"
#import "PPTableViewController.h"
#import "UserService.h"

typedef enum {
    FromWeixinOptionShareOpus = 0,
    FromWeixinOptionDrawAPicture = 1
}FromWeixinOption;

@class MyPaint;
@interface OpusManageController : CommonTabController  {
    
}

@property (retain, nonatomic) IBOutlet UIButton *clearButton;
@property (retain, nonatomic) IBOutlet UILabel *awardCoinTips;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (assign, nonatomic, getter = isFromWeiXin) BOOL fromWeiXin;

- (IBAction)deleteAll:(id)sender;

+ (void)shareFromWeiXin:(UIViewController*)superController;

- (id)initWithClass:(Class)aClass
             selfDb:(NSString*)selfDb
         favoriteDb:(NSString*)favoriteDb
            draftDb:(NSString*)draftDb;
@end
