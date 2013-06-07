//
//  GalleryPictureInfoEditView.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "CommonInfoView.h"

@protocol GalleryPictureInfoEditViewDelegate <NSObject>

- (void)didEditPictureInfo:(NSSet*)tagSet
                      name:(NSString*)name
                  imageUrl:(NSString*)url;

@end

@interface GalleryPictureInfoEditView : CommonInfoView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tagTable;
@property (assign, nonatomic) id<GalleryPictureInfoEditViewDelegate>delegate;
@property (retain, nonatomic) NSArray* tagPackageArray;
@property (retain, nonatomic) NSSet* tagSet;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) NSString* imageUrl;

+ (GalleryPictureInfoEditView*)createViewWithTagPackageArray:(NSArray*)packageArray
                                                    tagArray:(NSSet*)tagSet
                                                    imageUrl:(NSString*)url
                                                    delegate:(id<GalleryPictureInfoEditViewDelegate>)delegate;

- (IBAction)clickConfirm:(id)sender;

@end
