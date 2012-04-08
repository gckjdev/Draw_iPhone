//
//  ReplayController.h
//  Draw
//
//  Created by  on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyPaint;

@interface ReplayController : UIViewController

@property (nonatomic, assign) MyPaint *paint;

- (id)initWithPaint:(MyPaint*)paint;

@end
