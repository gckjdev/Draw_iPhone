//
//  PhotoEditView.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "CommonInfoView.h"

typedef void(^PhotoEditResultBLock)(NSString* name, NSSet* tagSet);

@protocol PhotoEditViewDelegate <NSObject>

- (void)didEditPictureInfo:(NSSet*)tagSet
                      name:(NSString*)name
                  imageUrl:(NSString*)url;

@end

@interface PhotoEditView : CommonInfoView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tagTable;
@property (assign, nonatomic) id<PhotoEditViewDelegate>delegate;
@property (retain, nonatomic) NSArray* tagPackageArray;
@property (retain, nonatomic) NSSet* tagSet;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) NSString* imageUrl;
@property (copy, nonatomic) PhotoEditResultBLock resultBlock;

+ (PhotoEditView*)createViewWithTagPackageArray:(NSArray*)packageArray
                                                    tagArray:(NSSet*)tagSet
                                                    imageUrl:(NSString*)url
                                                    delegate:(id<PhotoEditViewDelegate>)delegate;
//+ (PhotoEditView*)createViewWithPhoto:(pbuserp)

- (IBAction)clickConfirm:(id)sender;

@end
