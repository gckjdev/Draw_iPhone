//
//  SynthesisView.h
//  Draw
//
//  Created by Orange on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SynthesisView : UIView
{
    
}

@property(nonatomic, retain)UIImage *patternImage;
@property(nonatomic, retain)UIImage *drawImage;
- (UIImage*)createImage;
@end
