//
//  BBSBoardSection.h
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import <UIKit/UIKit.h>

@class PBBBSBoard;
@class BBSBoardSection;

@protocol BBSBoardSectionDelegate <NSObject>

@optional
- (void)didClickBoardSection:(BBSBoardSection *)boardSection
                    bbsBoard:(PBBBSBoard*)bbsBoard;

@end

@interface BBSBoardSection : UIView
{
    id<BBSBoardSectionDelegate> _delegate;
    PBBBSBoard *_bbsBoard;
}
@property (retain, nonatomic) IBOutlet UIImageView *icon;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *switchButton;
@property (assign, nonatomic) id<BBSBoardSectionDelegate> delegate;
@property (retain, nonatomic) PBBBSBoard *bbsBoard;

+ (BBSBoardSection *)createBoardSectionView:(id<BBSBoardSectionDelegate>)delegate;
- (void)setViewWithBoard:(PBBBSBoard *)board isOpen:(BOOL)isOpen;
- (IBAction)clickMaskButton:(id)sender;
+ (CGFloat)getViewHeight;
+ (NSString *)getViewIdentifer;
@end
