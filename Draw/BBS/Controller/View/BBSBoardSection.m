//
//  BBSBoardSection.m
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import "BBSBoardSection.h"
#import "Bbs.pb.h"
#import "UIImageView+WebCache.h"
@implementation BBSBoardSection

@synthesize bbsBoard = _bbsBoard;
@synthesize delegate = _delegate;
+ (BBSBoardSection *)createBoardSectionView:(id<BBSBoardSectionDelegate>)delegate;
{
    NSString *identifier = @"BBSBoardSection";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSBoardSection *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return  view;
}

- (void)setViewWithBoard:(PBBBSBoard *)board
{
    self.bbsBoard = board;
    [self.name setText:board.name];
    [self.topicCount setText:[NSString stringWithFormat:@"Topic:%d",board.topicCount]];
    [self.postCount setText:[NSString stringWithFormat:@"Post:%d",board.postCount]];
    NSURL *url = [NSURL URLWithString:board.icon];
    [self.icon setImageWithURL:url success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)clickMaskButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBoardSection:bbsBoard:)]) {
        [self.delegate didClickBoardSection:self bbsBoard:self.bbsBoard];
    }
}

+ (CGFloat)getViewHeight
{
    return 100.0;
}

- (void)dealloc {
    [_icon release];
    [_name release];
    [_topicCount release];
    [_postCount release];
    PPRelease(_bbsBoard);
    [super dealloc];
}
@end
