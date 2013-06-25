//
//  DrawToolUpPanel.h
//  Draw
//
//  Created by Kira on 13-6-25.
//
//

#import "DrawToolPanel.h"

@interface DrawToolUpPanel : DrawToolPanel

@property (retain, nonatomic) IBOutlet UIButton* copyPaint;
@property (assign, nonatomic) BOOL isVisable;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *drawToUserNickNameLabel;

- (void)appear;
- (void)disappear;
@end
