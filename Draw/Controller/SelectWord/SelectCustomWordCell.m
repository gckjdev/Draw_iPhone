//
//  SelectCustomWordCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-7.
//
//

#import "SelectCustomWordCell.h"
#import "ShareImageManager.h"

@implementation SelectCustomWordCell

+ (CGFloat)getCellHeight
{
    return 35 * ([DeviceDetection isIPAD] ? 2.18 : 1);
}

+ (NSString *)getCellIdentifier
{
    return @"SelectCustomWordCell" ;
}


- (void)setWord:(NSString *)word
{
    PPDebug(@"des: %@", self.wordLabel.description);
    self.wordLabel.text = word;
    
    SET_MESSAGE_LABEL_STYLE(self.wordLabel);
}


- (void)dealloc {
    [_wordLabel release];
    [super dealloc];
}
@end
