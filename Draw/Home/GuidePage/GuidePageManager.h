//
//  GuidePageManager
//  Draw
//
//  Created by ChaoSo on 14-7-21.
//
//

#import <Foundation/Foundation.h>
#import "ICETutorialController.h"
@interface GuidePageManager : PPViewController<ICETutorialControllerDelegate>
@property(nonatomic,retain) NSMutableArray *layerList;

-(ICETutorialController *)initGuidePage;
@end