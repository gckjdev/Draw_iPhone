//
//  CommonActionHeader.h
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewHeader.h"

@protocol CommonActionHeaderDelegate <NSObject>

@optional
- (void)didClickActionButton:(UIButton *)sender;

@end


@interface CommonActionHeader : PPTableViewHeader

- (IBAction)clickActionButton:(id)sender;

@end
