//
//  PhotoEditView.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

@class PBUserPhoto;

typedef void(^PhotoEditResultBLock)(NSSet* tagSet);

@interface PhotoEditView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) NSMutableSet* tagSet;

+ (PhotoEditView*)createViewWithPhoto:(PBUserPhoto*)photo;

- (void)reset;

@end
