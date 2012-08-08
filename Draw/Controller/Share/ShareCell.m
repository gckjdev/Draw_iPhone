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
#import "DrawUtils.h"
#import <QuartzCore/QuartzCore.h>
#include <ImageIO/ImageIO.h>
#include "CoreDataUtil.h"
#import "FileUtil.h"

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
    float imageButtonHeight;
    float imageButtonWidth;
    float seperator;
    
    if ([DeviceDetection isIPAD]) {
        imageButtonHeight = 170;
        imageButtonWidth = 150;
        seperator = 33.6;
    } else {
        imageButtonHeight = 85;
        imageButtonWidth = 75;
        seperator = 4;
    }
    
    for (int i = BASE_BUTTON_INDEX; i < BASE_BUTTON_INDEX + IMAGES_PER_LINE; ++i) {
       // MyPaintButton* button = [[MyPaintButton alloc] initWithFrame:CGRectMake((i-10)*79+4, 2, 75, 85)];
        MyPaintButton* button = [MyPaintButton creatMyPaintButton];
        [button setFrame:CGRectMake((i-BASE_BUTTON_INDEX)*(imageButtonWidth + seperator)+seperator, 2, imageButtonWidth, imageButtonHeight)];
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
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DRAW_VIEW_WIDTH/IMAGES_PER_LINE] forKey:(NSString*)kCGImageSourceThumbnailMaxPixelSize];
    
    int count = [imageArray count];
    BOOL hasUpdateThumbnailData = NO;
    
    for (int i = BASE_BUTTON_INDEX; i < BASE_BUTTON_INDEX + IMAGES_PER_LINE; ++i) {
        MyPaintButton *button = (MyPaintButton *)[self viewWithTag:i];
        
        int j = i - BASE_BUTTON_INDEX;
        if (button && j < count) {
            MyPaint *paint = [imageArray objectAtIndex:j];            
            NSData* data = nil;
            
            if (paint.drawThumbnailData == nil){
                NSString* homePath = [FileUtil getAppHomeDir];
                NSString* imageName = [FileUtil getFileNameByFullPath:paint.image];
                NSString* imagePath = [NSString stringWithFormat:@"%@/%@",homePath, imageName];
                data = [[[NSData alloc] initWithContentsOfFile:imagePath] autorelease];
                paint.drawThumbnailData = data;
                hasUpdateThumbnailData = YES;
            }
            else{
                data = paint.drawThumbnailData;
            }
            
            CGImageSourceRef imageRef = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)dict);            
//            UIImage* image = [UIImage imageWithCGImage:CGImageSourceCreateImageAtIndex(imageRef, 0, NULL)];
            CFRelease(imageRef);
            UIImage *image = [UIImage imageWithContentsOfFile:paint.image];
            
            [button.clickButton setImage:image forState:UIControlStateNormal];
            [button.drawWord setText:paint.drawWord];
            [button.myPrintTag setHidden:!paint.drawByMe.boolValue];
            button.hidden = NO;
            
        }else {
            button.hidden = YES;
        }
    }
    
    if (hasUpdateThumbnailData){
        [[CoreDataManager dataManager] save];
    }

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
