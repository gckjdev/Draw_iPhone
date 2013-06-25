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

- (void)appear;
- (void)disappear;
@end
