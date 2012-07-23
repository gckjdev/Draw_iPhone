#import "RecommendedAppCell.h"
#import "PPApplication.h"
#import "RecommendApp.h"

@implementation RecommendedAppCell

#pragma mark -
#pragma mark: implementation of PPTableViewCellProtocol
@synthesize imageView;
@synthesize titleLabel;
@synthesize briefIntroLabel;

+ (NSString*)getCellIdentifier
{
    return @"RecommendedAppCell";
}

+ (RecommendedAppCell*)creatCell
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RecommendedAppCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <RecommendedAppCell> but cannot find cell object from Nib");
        return nil;
    }
    
    return (RecommendedAppCell*)[topLevelObjects objectAtIndex:0];
}

#pragma mark -
#pragma mark: Customize the appearance of cell.
- (void)setCellData:(RecommendApp*)app
{
    titleLabel.text = app.appName;
    briefIntroLabel.text = app.appDescription;
    briefIntroLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255 alpha:1];
    [imageView.layer setCornerRadius:5.0f];
    [imageView.layer setMasksToBounds:YES];
    [self setAppIcon:app];
}

- (void)setAppIcon:(RecommendApp*)app
{
    [imageView clear];
    [imageView setUrl:[NSURL URLWithString:app.appIconUrl]];
    [GlobalGetImageCache() manage:imageView];
}

-(void) managedImageSet:(HJManagedImageV*)mi
{
}

-(void) managedImageCancelled:(HJManagedImageV*)mi
{
}

- (void)dealloc {
    [imageView release];
    [titleLabel release];
    [briefIntroLabel release];
    [super dealloc];
}

@end
