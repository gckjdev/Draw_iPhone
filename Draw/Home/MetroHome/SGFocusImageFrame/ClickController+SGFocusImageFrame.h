//
//  ClickController+SGFocusImageFrame.h
//  Draw
//
//  Created by ChaoSo on 14-7-17.
//
//

#import <Foundation/Foundation.h>
#import "SGFocusImageFrame.h"
#import "Billboard.h"

@interface SGFocusImageFrame(ClickController) : PPViewController
@property (nonatomic, retain) NSArray *bbList;
-(void)clickPageImage:(UIButton *)sender;

@end
