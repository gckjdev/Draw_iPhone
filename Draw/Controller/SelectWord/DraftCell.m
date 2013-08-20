//
//  DraftCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-7.
//
//

#import "DraftCell.h"
#import "ShareImageManager.h"

#define DRAFT_VIEW_TAG 200
#define DRAFT_NAME_LABEL_TAG 300

@interface DraftCell()

@property (retain, nonatomic) NSArray *drafts;

@end

@implementation DraftCell

- (void)dealloc
{
    [_drafts release];
    [super dealloc];
}

+ (CGFloat)getCellHeight
{
    return 82 * ([DeviceDetection isIPAD] ? 2 : 1);
}

+ (NSString *)getCellIdentifier
{
    return @"DraftCell";
}

- (void)setCellInfo:(NSArray *)drafts
{
    self.drafts = drafts;
    
    int index = 0;
    MyPaint *draft = nil;
    
    for (; index < [drafts count] && index < MAX_DRAFT_COUNT_PER_CELL; index++) {
        draft = [drafts objectAtIndex:index];
        [self setDraftWithIndex:index image:draft.thumbImage];
        [[self draftViewWithIndex:index] addTarget:self action:@selector(clickDraftButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([draft.isRecovery boolValue]){
            NSString* name = [NSString stringWithFormat:@"[%@] %@", NSLS(@"kRecoveryDraft"), draft.drawWord];
            [self setDraftNameWithIndex:index name:name];
            [self setDraftWithIndex:index image:[ShareImageManager defaultManager].autoRecoveryDraftImage];
        }
        else{
            [self setDraftNameWithIndex:index name:draft.drawWord];
        }
    }
    
    for (; index < MAX_DRAFT_COUNT_PER_CELL; index++) {
        [self setDraftWithIndex:index image:nil];
        [self setDraftNameWithIndex:index name:nil];
        [[self draftNameLabelWithIndex:index] setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setDraftWithIndex:(int)index image:(UIImage *)image
{
    [[self draftViewWithIndex:index] setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setDraftNameWithIndex:(int)index name:(NSString *)name
{
    [[self draftNameLabelWithIndex:index] setText:name];
}

- (UIButton *)draftViewWithIndex:(int)index
{
    UIView *view = [self viewWithTag:(DRAFT_VIEW_TAG + index)];
    if (![view isKindOfClass:[UIButton class]]) {
        return nil;
    }
    
    return (UIButton *)view;
}

- (UILabel *)draftNameLabelWithIndex:(int)index
{
    UIView *view = [self viewWithTag:(DRAFT_NAME_LABEL_TAG + index)];
    if (![view isKindOfClass:[UILabel class]]) {
        return nil;
    }
    
    return (UILabel *)view;
}

- (void)clickDraftButton:(id)sender
{
    int index = ((UIButton *)sender).tag - DRAFT_VIEW_TAG;
    if (index >= [_drafts count]) {
        return;
    }
    
    if ([delegate respondsToSelector:@selector(didClickDraft:)]) {
        [delegate didClickDraft:[_drafts objectAtIndex:index]];
    }
}


@end
