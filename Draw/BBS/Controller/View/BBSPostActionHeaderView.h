//
//  BBSPostActionHeaderView.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import <UIKit/UIKit.h>

@interface BBSPostActionHeaderView : UIView
@property (retain, nonatomic) IBOutlet UIButton *support;
@property (retain, nonatomic) IBOutlet UIButton *comment;

- (IBAction)clickSupport:(id)sender;
- (IBAction)clickComment:(id)sender;
@end
