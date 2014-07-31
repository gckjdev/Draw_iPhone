//
//  GifViewController.h
//  Draw
//
//  Created by 黄毅超 on 14-7-30.
//
//

#import <UIKit/UIKit.h>
#import "DrawHolderView.h"

@interface GifViewController : UIViewController <UIGestureRecognizerDelegate>
{
    
}

@property (nonatomic, retain) NSData* gifData;
@property (nonatomic, retain) UIView* subView;

- (void) showGif;

@end
