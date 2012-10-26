//
//  PokerView.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <UIKit/UIKit.h>

@interface PokerView : UIView

@property (retain, nonatomic) IBOutlet UIView *fontView;
@property (retain, nonatomic) IBOutlet UIImageView *rankImageView;
@property (retain, nonatomic) IBOutlet UIImageView *suitImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bodyImageView;

@property (retain, nonatomic) IBOutlet UIImageView *backImageView;

- (void)faceDown:(BOOL)animation;
- (void)faceUp:(BOOL)animation;

@end
