//
//  LearnDrawPreViewController.h
//  Draw
//
//  Created by gamy on 13-4-15.
//
//

#import "PPViewController.h"
#import "DrawFeed.h"

@interface LearnDrawPreViewController : PPViewController

+ (LearnDrawPreViewController *)enterLearnDrawPreviewControllerFrom:(UIViewController *)fromController
                                                             drawFeed:(DrawFeed *)drawFeed
                                                     placeHolderImage:(UIImage *)image;

@end
