//
//  PhotoEditView.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "PhotoEditView.h"
#import "AutoCreateViewByXib.h"

@interface PhotoEditView ()


@end

@implementation PhotoEditView

AUTO_CREATE_VIEW_BY_XIB(PhotoEditView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (PhotoEditView*)createViewWithTagPackageArray:(NSArray*)packageArray
                                                    tagArray:(NSSet*)tagSet
                                                    imageUrl:(NSString*)url
                                                    delegate:(id<PhotoEditViewDelegate>)delegate
{
    PhotoEditView* view = [self createView];
    view.tagPackageArray = packageArray;
    view.delegate = delegate;
    view.tagSet = tagSet;
    view.tagTable.delegate = view;
    view.tagTable.dataSource = view;
    view.nameTextField.delegate = view;
    view.imageUrl = url;
    return view;
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagPackageArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (IBAction)clickConfirm:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didEditPictureInfo:name:imageUrl:)]) {
        [_delegate didEditPictureInfo:self.tagSet name:self.nameTextField.text imageUrl:self.imageUrl];
    }
    [self disappear];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [_tagTable release];
    [_tagPackageArray release];
    [_tagSet release];
    [_nameTextField release];
    [_imageUrl release];
    [super dealloc];
}
@end
