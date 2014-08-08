//
//  GuidePageManager
//  Draw
//
//  Created by ChaoSo on 14-7-21.
//
//

#import <Foundation/Foundation.h>
#import "ICETutorialController.h"

@interface GuidePageManager : ICETutorialController<ICETutorialControllerDelegate>

@property(nonatomic,retain) NSMutableArray *layerList;
@property (retain, nonatomic) NSString *xiaojiNumber;
@property (retain, nonatomic) NSString *password;
@property (assign, nonatomic) UIViewController *superController;

+ (void)showGuidePage:(UIViewController*)superController;

@end
