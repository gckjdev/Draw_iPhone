//
//  SingGuessController.h
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "PPViewController.h"
#import "WordInputView.h"
#import "Opus.h"

@interface SingGuessController : PPViewController
@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;
@property (retain, nonatomic) PBOpus *pbOpus;

- (id)initWithPBOpus:(PBOpus *)pbOpus;

@end
