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
@property (retain, nonatomic) IBOutlet UIButton *copyPaintPicker;
@property (retain, nonatomic) IBOutlet UILabel *drawToUserNickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *copyPaintLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)clickShowCopyPaint:(id)sender;

- (void)appear:(UIViewController*)parentController
         title:(NSString*)title
   isLeftArrow:(BOOL)isLeftArrow;
- (void)disappear;

- (void)updateCopyPaint:(UIImage*)aPhoto;
@end
