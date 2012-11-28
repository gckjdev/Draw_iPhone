//
//  BBSBoardSection.m
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import "BBSBoardSection.h"
#import "BBSModelExt.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"

@implementation BBSBoardSection

@synthesize bbsBoard = _bbsBoard;
@synthesize delegate = _delegate;

+ (BBSBoardSection *)createBoardSectionView:(id<BBSBoardSectionDelegate>)delegate;
{
    NSString *identifier = [BBSBoardSection getViewIdentifer];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSBoardSection *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;


    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    BBSColorManager *colorManager = [BBSColorManager defaultManager];
    BBSFontManager *fontManager = [BBSFontManager defaultManager];
    [view.bgImageView setImage:[imageManager bbsSectionBgImage]];
    [BBSViewManager updateLable:view.name
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexSectionNameFont]
                      textColor:[colorManager sectionTitleColor]
                           text:nil];
    [view.switchButton setBackgroundImage:[imageManager bbsSwitchBgImage]
                                 forState:UIControlStateNormal];
    [view.switchButton setImage:[imageManager bbsSwitchRightImage]
                       forState:UIControlStateNormal];
    [view.switchButton setImage:[imageManager bbsSwitchDownImage]
                       forState:UIControlStateSelected];


    return  view;
}

- (void)setViewWithBoard:(PBBBSBoard *)board isOpen:(BOOL)isOpen
{
    self.bbsBoard = board;
    [self.icon setImageWithURL:board.iconURL];
    [self.name setText:board.name];
    [self.switchButton setSelected:isOpen];
}

- (IBAction)clickMaskButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBoardSection:bbsBoard:)]) {
        [self.delegate didClickBoardSection:self bbsBoard:self.bbsBoard];
    }
}

+ (CGFloat)getViewHeight
{
    return [DeviceDetection isIPAD] ? 69 : 35;
}

+ (NSString *)getViewIdentifer
{
    return @"BBSBoardSection";
}
- (void)dealloc {
    [_icon release];
    [_name release];
    PPRelease(_bbsBoard);
    [_bgImageView release];
    [_switchButton release];
    [super dealloc];
}
@end
