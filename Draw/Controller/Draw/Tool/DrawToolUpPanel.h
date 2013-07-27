//
//  DrawToolUpPanel.h
//  Draw
//
//  Created by Kira on 13-6-25.
//
//

#import "DrawToolPanel.h"
#import "DrawView.h"
#import "MyFriend.h"

@interface DrawToolUpPanel : DrawToolPanel

@property (assign, nonatomic) BOOL isVisable;


@property (retain, nonatomic) IBOutlet UIButton* copyPaint;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *copyPaintPicker;
@property (retain, nonatomic) IBOutlet UILabel *drawToUserNickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *copyPaintLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (retain, nonatomic) IBOutlet UIButton *canvasSize;
@property (retain, nonatomic) IBOutlet UIButton *grid;
@property (retain, nonatomic) IBOutlet UIButton *opusDesc;
@property (retain, nonatomic) IBOutlet UIButton *drawToUser;
@property (retain, nonatomic) IBOutlet UIButton *help;
@property (retain, nonatomic) IBOutlet UIButton *drawBg;

@property (retain, nonatomic) IBOutlet UIButton *subject;



- (IBAction)clickShowCopyPaint:(id)sender;

- (void)appear:(UIViewController*)parentController
         title:(NSString*)title
   isLeftArrow:(BOOL)isLeftArrow;
- (void)disappear;
- (void)updateDrawToUser:(MyFriend *)user;
- (void)registerToolCommands;
- (void)updateCopyPaint:(UIImage*)aPhoto;
@end
