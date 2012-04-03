//
//  ShareCell.h
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShareCellDelegate <NSObject>

- (void)selectImageAtIndex:(int)index;

@end

@interface ShareCell : UITableViewCell <UIActionSheetDelegate>
{
    
}
//@property (retain, nonatomic) IBOutlet UIButton *leftButton;
//@property (retain, nonatomic) IBOutlet UIButton *middleButton;
//@property (retain, nonatomic) IBOutlet UIButton *rightButton;
@property (retain, nonatomic) NSIndexPath* indexPath;
@property (assign, nonatomic) id<ShareCellDelegate> delegate;
+ (ShareCell*)creatShareCell;
+ (ShareCell*)creatShareCellWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ShareCellDelegate>)aDelegate;
+ (NSString*)getIdentifier;
- (void)setImagesWithArray:(NSArray*)imageArray;
- (IBAction)clickImageButton:(id)sender;
@end
