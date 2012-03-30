//
//  ShareEditController.h
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareEditController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) UIImage* myImage;

- (id)initWithImage:(UIImage*)anImage;
@end
