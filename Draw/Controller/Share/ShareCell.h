//
//  ShareCell.h
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCell : UITableViewCell 
{
    
}
@property (retain, nonatomic) IBOutlet UIButton *leftButton;
@property (retain, nonatomic) IBOutlet UIButton *middleButton;
@property (retain, nonatomic) IBOutlet UIButton *rightButton;
+ (ShareCell*)creatShareCell;
+ (NSString*)getIdentifier;
@end
