//
//  SongTagCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import "SongTagCell.h"
#import "UIViewUtils.h"
#import "UIColor+UIColorExt.h"

#define GAP (ISIPAD ? 8 : 4)
#define FIRST_TAG_ORIGIN_X  (ISIPAD ? 36 : 16)
#define FIRST_TAG_ORIGIN_Y  (ISIPAD ? 102 : 47)
#define TAG_WIDTH  (ISIPAD ? 126 : 58)
#define TAG_HEIGHT (ISIPAD ? 50 : 23)
#define TAG_FONT (ISIPAD ? [UIFont systemFontOfSize:28] : [UIFont systemFontOfSize:14])

#define UNSELECTED_COLOR [UIColor colorWithRed:42/255.0 green:140/255.0 blue:204/255.0 alpha:1]
#define SELECTED_COLOR [UIColor whiteColor]

@interface SongTagCell()

@property (retain, nonatomic) UIButton *selectedButton;

@end


@implementation SongTagCell

- (void)dealloc{
    
    [_selectedButton release];
    [_categoryLabel release];
    [_seperator release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    return @"SongTagCell";
}

+ (CGFloat)getCellHeightWithCategory:(NSDictionary *)category{
    
    NSArray *tag = [[category allValues] objectAtIndex:0];
    return FIRST_TAG_ORIGIN_Y + GAP*2 + TAG_HEIGHT * ceil([tag count] / TagsPerCell);
}

- (void)setCellInfo:(NSDictionary *)category{

    for (UIView *view in self.subviews) {
        if ([[view class] isSubclassOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self updateHeight:[SongTagCell getCellHeightWithCategory:category]];
    
    self.categoryLabel.text = [[category allKeys] objectAtIndex:0];

    NSArray *tags = [[category allValues] objectAtIndex:0];
    int count = [tags count];
    for (int index = 0; index < count; index++) {
        
        NSString *tag = [tags objectAtIndex:index];
        UIButton *button = [self buttonWithTitle:tag index:index];
        [self addSubview:button];
    }
    
    [self.seperator updateOriginY:(self.frame.size.height - self.seperator.frame.size.height)];
}

- (UIButton *)buttonWithTitle:(NSString *)title index:(int)index{
    
    CGFloat originX = FIRST_TAG_ORIGIN_X + (TAG_WIDTH + GAP) * (index%(int)TagsPerCell);
    CGFloat originY = FIRST_TAG_ORIGIN_Y + (TAG_HEIGHT) * (index / (int)TagsPerCell);
    
    CGRect rect = CGRectMake(originX, originY, TAG_WIDTH, TAG_HEIGHT);
    
    UIButton *button = [[[UIButton alloc] initWithFrame:rect] autorelease];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = TAG_FONT;
    
    NSString *selectedTag = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SONG_CATEGORY_TAG];
    
    if ([title isEqualToString:selectedTag]) {
        [button setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
        self.selectedButton = button;
    }else{
        [button setTitleColor:UNSELECTED_COLOR forState:UIControlStateNormal];
    }
    
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)clickButton:(UIButton *)button{
    
    [_selectedButton setTitleColor:UNSELECTED_COLOR forState:UIControlStateNormal];
    self.selectedButton = button;
    
    if ([delegate respondsToSelector:@selector(didClickTag:)]) {
        [button setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
        NSString *tag = [button titleForState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:tag forKey:KEY_SONG_CATEGORY_TAG];
        [delegate didClickTag:tag];
    }
}


@end
