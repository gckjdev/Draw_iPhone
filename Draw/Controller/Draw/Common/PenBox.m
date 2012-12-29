//
//  PenBox.m
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import "PenBox.h"

@interface PenBox()
{
    
}

- (IBAction)clickPen:(UIButton *)sender;

@end

@implementation PenBox

- (void)updateView
{
    
}

+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"PenBox";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    PenBox  *view = (PenBox *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
}

- (IBAction)clickPen:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(penBox:didSelectPen:penImage:)]) {
        UIImage *image = [sender imageForState:UIControlStateNormal];
        [self.delegate penBox:self didSelectPen:sender.tag penImage:image];
    }
}
@end
