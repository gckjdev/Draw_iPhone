//
//  AddLearnDrawView.h
//  Draw
//
//  Created by gamy on 13-4-12.
//
//

#import <UIKit/UIKit.h>

@interface AddLearnDrawView : UIView

- (NSInteger)price;
- (NSInteger)type;

- (void)showInView:(UIView *)view;
//- (void)dismiss;
+ (id)createViewWithOpusId:(NSString *)opusId;
@end
