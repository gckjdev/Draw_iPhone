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

#define BUTTON_TITLE_EDGEINSETS     (ISIPAD ? -195 : -99)
#define BOTTOM_BUTTON_HEIGHT (ISIPAD ? 160 : 90)

-(void)updateMoreCollectionCell:(NSInteger)row type:(int)type
{
    
    [self.itemButton setBackgroundColor:[UIColor clearColor]];
    
    //set title
    NSString *title = [MoreViewController getItemTitle:row];
    [self.titleLabel setText:title];
    [self.titleLabel setFont:AD_BOLD_FONT(20, 12)];
    [self.titleLabel setTextColor:COLOR_BROWN];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    //set image
    if (type == SpecialTypeUser){
        [self.itemButton setBackgroundImage:nil forState:UIControlStateNormal];

        //set avatar view
        [self.avatarView setHidden:NO];
        [self.avatarView setAvatarUrl:[[UserManager defaultManager] avatarURL]
                               gender:[[UserManager defaultManager] boolGender]
                       useDefaultLogo:YES];
    }
    else{
        UIImage *image = [MoreViewController getItemImage:row];
        [self.itemButton setBackgroundImage:image forState:UIControlStateNormal];
        
        [self.avatarView setHidden:YES];
    }

    
    
    int badge = [MoreViewController getItemBadge:row];
    [self.badgeView setNumber:badge];
    
    [self setCurrentRow:row];
    [self setCurrentType:type];
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
    [_avatarView release];
    [_badgeView release];
    [_itemButton release];
    [_titleLabel release];
    [super dealloc];
}

-(IBAction)clickButton:(id)sender
{
    [self.controller handleClickItem:self.currentRow];
}
@end