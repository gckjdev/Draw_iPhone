//
//  AnnounceView.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Announce.h"

@class AnnounceView;
@protocol AnnounceViewDelegate <NSObject>

@optional 
- (void)announceView:(AnnounceView *)announceView 
   didCaptureRequest:(NSURLRequest *)request;

@end

@interface AnnounceView : UIView
{
    Announce *_announce;
}

@property(nonatomic, retain)Announce *announce;
- (id)initWithAnnounce:(Announce *)anounce;
+ (AnnounceView *)creatAnnounceView:(Announce *)annnouce;
- (void)loadView;

@end
