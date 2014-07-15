//
//  MoreViewCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-14.
//
//

#import "MoreViewCell.h"
#import "HomeMenuView.h"
#import "SuperHomeController.h"
#import "MoreViewController.h"

@implementation MoreViewCell


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //TODO
        
    }
    return self;
}

#define BUTTON_TITLE_EDGEINSETS     (ISIPAD ? -42 : -99)
#define BOTTOM_BUTTON_HEIGHT (ISIPAD ? 52 : 90)

-(void)updateMoreCollectionCell:(NSInteger)row{
    [self.itemButton setBackgroundColor:[UIColor clearColor]];
    //set title
    NSString *title = [MoreViewController getItemTitle:row];
    [self.itemButton setTitle:title forState:UIControlStateNormal];
    [self.itemButton setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_HEIGHT, BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.itemButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [self.itemButton.titleLabel setFont:AD_BOLD_FONT(20, 12)];
    //set image
    UIImage *imageName = [MoreViewController getItemImage:row];
    [self.itemButton setImage:imageName forState:UIControlStateNormal];
    
    [self.badgeView setNumber:5];
    
    [self setCurrentRow:row];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




- (void)dealloc {
    [_badgeView release];
    [_itemButton release];
    [super dealloc];
}

-(IBAction)clickButton:(id)sender
{
    [self.controller handleClickItem:self.currentRow];
}
@end