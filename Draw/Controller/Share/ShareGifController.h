//
//  ShareGifController.h
//  Draw
//
//  Created by Orange on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSServiceDelegate.h"

@interface ShareGifController : UIViewController <SNSServiceDelegate, UIActionSheetDelegate>{
    NSArray* _gifFrames;
}

@property (retain, nonatomic) NSArray* gifFrames;
@property (retain, nonatomic) IBOutlet UIImageView *inputBackground;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;

- (id)initWithGifFrames:(NSArray*)frames;
@end
