//
//  UMUFPTableViewCell.h
//  UFP
//
//  Created by liu yu on 2/13/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMImageView;

@interface UMTableViewCell : UITableViewCell {
@private
	UMImageView* _mImageView;
}

@property (nonatomic, retain) UMImageView* mImageView;

- (void)setImageURL:(NSString*)urlStr;

@end
