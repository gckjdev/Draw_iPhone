//
//  ShowImageController.h
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "PPViewController.h"

@interface ShowImageController : PPViewController

+ (ShowImageController *)enterControllerWithImage:(UIImage *)image
                                   fromController:(UIViewController *)fromController
                                         animated:(BOOL)animated;

+ (ShowImageController *)enterControllerWithImageURL:(NSURL *)imageURL
                                   fromController:(UIViewController *)fromController
                                         animated:(BOOL)animated;

@end
