//
//  StageCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-2.
//
//

#import "StageCell.h"
#import "UIImageView+Extend.h"

@implementation StageCell
#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
            //TODO
        
            }
    return self;
}
-(void)updateStageCellInfo:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row{
    
        SET_BUTTON_ROUND_STYLE_ORANGE(self.stageListStarBtn);
            
        NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
        //加载图片
        UIImage *placeHolderImage = [UIImage imageNamed:@"dialogue@2x"];
        SET_VIEW_ROUND_CORNER(self.stageCellImage);
        [self.stageCellImage
         setImageWithUrl:[NSURL URLWithString:[[stageList objectAtIndex:row] thumbImage]]
         placeholderImage:placeHolderImage
         showLoading:YES
         animated:YES];
        //设置label文字
        self.cellName.text = [[stageList objectAtIndex:row] cnName];
    
}

- (void)dealloc {
    [_stageCellImage release];
    [_cellName release];
    [_stageListStarBtn release];
    [super dealloc];
}
@end
