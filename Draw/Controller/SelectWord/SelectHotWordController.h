//
//  SelectHotWordController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-3.
//
//

#import <UIKit/UIKit.h>
#import "WordSelectCell.h"

@interface SelectHotWordController : UIViewController <WordSelectCellDelegate>
@property (retain, nonatomic) IBOutlet UIView *hotWordsView;
@property (retain, nonatomic) IBOutlet UIView *systemWordsView;
@property (retain, nonatomic) IBOutlet UIView *myWordsView;

@property (retain, nonatomic) WordSelectCell *hotWordsCell;
@property (retain, nonatomic) WordSelectCell *systemWordsCell;
@property (retain, nonatomic) WordSelectCell *myWordsCell;
@property (retain, nonatomic) IBOutlet WordSelectCell *hotWordsCellPlaceHolder;
@property (retain, nonatomic) IBOutlet WordSelectCell *systemWordsCellPlaceHolder;
@property (retain, nonatomic) IBOutlet WordSelectCell *myWordsCellPlaceHolder;

@end
