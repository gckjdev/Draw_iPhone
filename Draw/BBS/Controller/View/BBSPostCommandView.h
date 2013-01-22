//
//  PostCommandView.h
//  Draw
//
//  Created by gamy on 13-1-22.
//
//

#import <UIKit/UIKit.h>


@class BBSPostCommand;
@interface BBSPostCommandView : UIButton

@property(nonatomic, retain)BBSPostCommand *command;
+ (id)commandViewWithCommand:(BBSPostCommand *)command;
+ (CGFloat)viewWidth;
@end
