//
//  SingHotCell.h
//  Draw
//
//  Created by 王 小涛 on 13-12-13.
//
//

#import "PPTableViewCell.h"

@interface SingHotCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIView *holderView1;
@property (retain, nonatomic) IBOutlet UIView *holderView2;
@property (retain, nonatomic) IBOutlet UIView *holderView3;

- (void)setCellInfo:(NSArray *)feeds;

@end
