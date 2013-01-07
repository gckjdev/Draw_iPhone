//
//  SelectCustomWordCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-7.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@interface SelectCustomWordCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *wordLabel;

- (void)setWord:(NSString *)word;
@end
