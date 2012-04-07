//
//  ShareGifController.h
//  Draw
//
//  Created by Orange on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSServiceDelegate.h"

@interface ShareGifController : UIViewController <SNSServiceDelegate>{
    NSArray* _gifFrames;
}

@property (retain, nonatomic) NSArray* gifFrames;

- (id)initWithGifFrames:(NSArray*)frames;
@end
