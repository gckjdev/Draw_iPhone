//
//  PhotoEditView.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "CommonInfoView.h"

@class PBUserPhoto;

typedef void(^PhotoEditResultBLock)(NSString* name, NSSet* tagSet);

@interface PhotoEditView : CommonInfoView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (copy, nonatomic) PhotoEditResultBLock resultBlock;

+ (PhotoEditView*)createViewWithPhoto:(PBUserPhoto*)photo
                             editName:(BOOL)editName
                          resultBlock:(PhotoEditResultBLock)resultBlock;

- (IBAction)clickConfirm:(id)sender;

@end
