//
//  SelectHotWordController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-3.
//
//

#import <UIKit/UIKit.h>
#import "WordSelectCell.h"
#import "SelectCustomWordView.h"
#import "DraftsView.h"

@interface SelectHotWordController : UIViewController <WordSelectCellDelegate, SelectCustomWordViewDelegate, DraftsViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UILabel *hotWordsLabel;
@property (retain, nonatomic) IBOutlet UILabel *hotWordsNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *systemWordsLabel;
@property (retain, nonatomic) IBOutlet UILabel *myWordsLabel;

@property (retain, nonatomic) IBOutlet UIView *hotWordsView;
@property (retain, nonatomic) IBOutlet UIView *systemWordsView;
@property (retain, nonatomic) IBOutlet UIView *myWordsView;
@property (retain, nonatomic) IBOutlet UIButton *draftsBoxButton;

@property (retain, nonatomic) WordSelectCell *hotWordsCell;
@property (retain, nonatomic) WordSelectCell *systemWordsCell;
@property (retain, nonatomic) WordSelectCell *myWordsCell;
@property (retain, nonatomic) IBOutlet WordSelectCell *hotWordsCellPlaceHolder;
@property (retain, nonatomic) IBOutlet WordSelectCell *systemWordsCellPlaceHolder;
@property (retain, nonatomic) IBOutlet WordSelectCell *myWordsCellPlaceHolder;

@end
