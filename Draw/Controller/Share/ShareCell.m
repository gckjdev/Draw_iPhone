//
//  ShareCell.m
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareCell.h"
#import "MyPaint.h"
#import "UIImageUtil.h"

@implementation ShareCell
//@synthesize leftButton;
//@synthesize middleButton;
//@synthesize rightButton;
@synthesize indexPath = _indexPath;
@synthesize delegate = _delegate;

#define BASE_BUTTON_INDEX 10
+ (ShareCell*)creatShareCell
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <ShareCell> but cannot find cell object from Nib");
        return nil;
    }
    ShareCell* cell =  (ShareCell*)[topLevelObjects objectAtIndex:0];
    return cell;
}

+ (ShareCell*)creatShareCellWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ShareCellDelegate>)aDelegate
{
    ShareCell* cell = [self creatShareCell];
    cell.indexPath = indexPath;
    cell.delegate = aDelegate;
    for (int i = BASE_BUTTON_INDEX; i < BASE_BUTTON_INDEX + IMAGES_PER_LINE; ++i) {
       // MyPaintButton* button = [[MyPaintButton alloc] initWithFrame:CGRectMake((i-10)*79+4, 2, 75, 85)];
        MyPaintButton* button = [MyPaintButton creatMyPaintButton];
        [button setFrame:CGRectMake((i-10)*79+4, 2, 75, 85)];
        button.delegate= cell;
        button.tag = i;
        [cell addSubview:button];
        //[button release];
    }
    return cell;
}

+ (NSString*)getIdentifier
{
    return @"ShareCell";
}

- (void)setImagesWithArray:(NSArray*)imageArray
{
    for (int i = BASE_BUTTON_INDEX; i < BASE_BUTTON_INDEX + IMAGES_PER_LINE; ++i) {
        MyPaintButton *button = (MyPaintButton *)[self viewWithTag:i];
        
        // image view start from 30, button start from 10, the gap is 20
        //UIImageView* bgImageView = (UIImageView *)[self viewWithTag:i+20]; 
        int j = i - BASE_BUTTON_INDEX;
        if (button && j < [imageArray count]) {
            MyPaint *paint = [imageArray objectAtIndex:j];
            NSData* data = [[NSData alloc] initWithContentsOfFile:paint.image];
            UIImage* image = [UIImage creatThumbnailsWithData:data withSize:CGSizeMake(70, 75)];
            [button.clickButton setImage:image forState:UIControlStateNormal];
            [button.drawWord setText:paint.drawWord];
            [button.myPrintTag setHidden:!paint.drawByMe.boolValue];
            button.hidden = NO;
            [data release];
            //bgImageView.hidden = NO;
            
        }else {
            button.hidden = YES;
            //bgImageView.hidden = YES;
        }
    }
//    NSArray* buttonsArray = [NSArray arrayWithObjects:self.leftButton, self.middleButton, self.rightButton, nil];
//    for (UIButton* btn in buttonsArray) {
//        [btn setHidden:YES];
//    }
//    for (int index = 0; index < imageArray.count; index ++) {
//        UIButton* btn = [buttonsArray objectAtIndex:index];
//        [btn setImage:[imageArray objectAtIndex:index]  forState:UIControlStateNormal];
//        [btn setHidden:NO];
//    }
}

- (void)clickImage:(MyPaintButton *)myPaintButton
{
    int j = myPaintButton.tag - BASE_BUTTON_INDEX;
    if (_delegate && [_delegate respondsToSelector:@selector(selectImageAtIndex:)]) {
        [_delegate selectImageAtIndex:self.indexPath.row*IMAGES_PER_LINE + j];
    }
}

- (IBAction)clickImageButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    int j = button.tag - BASE_BUTTON_INDEX;
    if (_delegate && [_delegate respondsToSelector:@selector(selectImageAtIndex:)]) {
        [_delegate selectImageAtIndex:self.indexPath.row*IMAGES_PER_LINE + j];
    }

}

//- (IBAction)cliekLeftButton:(id)sender
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(selectImageAtIndex:)]) {
//        [_delegate selectImageAtIndex:self.indexPath.row*3];
//    }
//}
//
//- (IBAction)cliekMiddleButton:(id)sender
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(selectImageAtIndex:)]) {
//        [_delegate selectImageAtIndex:self.indexPath.row*3+1];
//    }
//}
//
//- (IBAction)cliekRightButton:(id)sender
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(selectImageAtIndex:)]) {
//        [_delegate selectImageAtIndex:self.indexPath.row*3+2];
//    }
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
//    [leftButton release];
//    [middleButton release];
//    [rightButton release];
    [_indexPath release];
    [super dealloc];
}
@end
