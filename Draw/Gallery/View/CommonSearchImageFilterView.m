//
//  CommonSearchImageFilterView.m
//  Draw
//
//  Created by Kira on 13-6-5.
//
//

#import "CommonSearchImageFilterView.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "AutoCreateViewByXib.h"

#define FILE_TYPE_OFFSET    20130605
#define IMAGE_GRAY_OFFSET   120130605
#define IMAGE_COLOR_OFFSET  220130605
#define IMAGE_SIZE_OFFSET   320120605
#define IMAGE_TYPE_OFFSET   420120605

@interface CommonSearchImageFilterView () {
    
}
@property (retain, nonatomic) NSMutableDictionary* filter;
@property (assign, nonatomic) id<CommonSearchImageFilterViewDelegate>delegate;

- (IBAction)clickCancelBtn:(id)sender;

@end

@implementation CommonSearchImageFilterView

AUTO_CREATE_VIEW_BY_XIB(CommonSearchImageFilterView)

- (void)dealloc
{
    [_filter release];
    [super dealloc];
}

+ (NSArray*)valueArrayForKey:(NSString*)key
{
    if ([key isEqualToString:PARA_FILE_TYPE]) {
        return [NSArray arrayWithObjects:@"jpg",@"png",@"bmp",nil];
    } else if ([key isEqualToString:PARA_IMAGE_COLOR]) {
        return [NSArray arrayWithObjects:@"black",@"blue",@"brown",@"gray",@"green",@"orange",@"pink",@"purple",@"red",@"teal",@"white",@"yellow",nil];
    } else if ([key isEqualToString:PARA_IMAGE_GRAY]) {
        return [NSArray arrayWithObjects:@"color",@"gray",nil];
    } else if ([key isEqualToString:PARA_IMAGE_SIZE]) {
        return [NSArray arrayWithObjects:@"icon",@"xlarge",@"xxlarge",@"huge",nil];
    }
    else if ([key isEqualToString:PARA_IMAGE_TYPE]) {
        return [NSArray arrayWithObjects:@"face",@"photo",@"clipart",@"lineart",nil];
    }
    return nil;
}

+ (NSArray*)NameArrayForKey:(NSString*)key
{
    if ([key isEqualToString:PARA_IMAGE_GRAY]) {
        return [NSArray arrayWithObjects:NSLS(@"kColorful"),NSLS(@"KBlackAndWhite"),nil];
    } else if ([key isEqualToString:PARA_IMAGE_SIZE]) {
        return [NSArray arrayWithObjects:NSLS(@"kIcon"),NSLS(@"kMedium"),NSLS(@"kLarge"),NSLS(@"kHuge"),nil];
    }
    else if ([key isEqualToString:PARA_IMAGE_TYPE]) {
        return [NSArray arrayWithObjects:NSLS(@"kFace"),NSLS(@"kPhoto"),NSLS(@"kClipart"),NSLS(@"kLineart"),nil];
    }
    return nil;
}

- (NSString*)getKeyByOffset:(int)offset
{
    switch (offset) {
        case FILE_TYPE_OFFSET:
            return PARA_FILE_TYPE;
            break;
        case IMAGE_COLOR_OFFSET: {
            return PARA_IMAGE_COLOR;
        } break;
        case IMAGE_GRAY_OFFSET: {
            return PARA_IMAGE_GRAY;
        } break;
        case IMAGE_SIZE_OFFSET: {
            return PARA_IMAGE_SIZE;
        } break;
        case IMAGE_TYPE_OFFSET: {
            return PARA_IMAGE_TYPE;
        } break;
        default:
            break;
    }
    return nil;
}

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+ (CommonSearchImageFilterView*)createViewWithFilter:(NSMutableDictionary*)filter delegate:(id<CommonSearchImageFilterViewDelegate>)delegate
{
    CommonSearchImageFilterView* view = [self createView];
    view.delegate = delegate;
    view.filter = [[[NSMutableDictionary alloc] initWithDictionary:filter]  autorelease];
    for (NSString* key in [filter allKeys]) {
        [view initViewWithKey:key filter:filter];
    }
    [view initBtns];
    return view;
}

- (void)initBtns
{
    [self.confirmBtn setTitle:NSLS(@"kConfirm") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    
    [self initGroupForKey:PARA_IMAGE_GRAY];
    [self initGroupForKey:PARA_IMAGE_SIZE];
    [self initGroupForKey:PARA_IMAGE_TYPE];
    [self initGroupForKey:PARA_IMAGE_COLOR];
    
}

- (void)initGroupForKey:(NSString*)key
{
    if ([key isEqualToString:PARA_IMAGE_GRAY]) {
        NSArray* nameArray = [CommonSearchImageFilterView NameArrayForKey:key];
        UIButton* defBtn = (UIButton*)[self viewWithTag:IMAGE_GRAY_OFFSET];
        [defBtn setTitle:NSLS(@"kUnlimit") forState:UIControlStateNormal];
        for (int i = 1; i <= nameArray.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:(IMAGE_GRAY_OFFSET+i)];
            NSString* title = [nameArray objectAtIndex:(i-1)];
            [btn setTitle:title forState:UIControlStateNormal];
        }
    }
    
    if ([key isEqualToString:PARA_IMAGE_SIZE]) {
        NSArray* nameArray = [CommonSearchImageFilterView NameArrayForKey:key];
        UIButton* defBtn = (UIButton*)[self viewWithTag:IMAGE_SIZE_OFFSET];
        [defBtn setTitle:NSLS(@"kUnlimit") forState:UIControlStateNormal];
        for (int i = 1; i <= nameArray.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:(IMAGE_SIZE_OFFSET+i)];
            NSString* title = [nameArray objectAtIndex:(i-1)];
            [btn setTitle:title forState:UIControlStateNormal];
        }
    }
    
    if ([key isEqualToString:PARA_IMAGE_TYPE]) {
        NSArray* nameArray = [CommonSearchImageFilterView NameArrayForKey:key];
        UIButton* defBtn = (UIButton*)[self viewWithTag:IMAGE_TYPE_OFFSET];
        [defBtn setTitle:NSLS(@"kUnlimit") forState:UIControlStateNormal];
        for (int i = 1; i <= nameArray.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:(IMAGE_TYPE_OFFSET+i)];
            NSString* title = [nameArray objectAtIndex:(i-1)];
            [btn setTitle:title forState:UIControlStateNormal];
        }
    }
    
    if ([key isEqualToString:PARA_IMAGE_COLOR]) {
        UIButton* defBtn = (UIButton*)[self viewWithTag:IMAGE_COLOR_OFFSET];
        [defBtn setTitle:NSLS(@"kUnlimit") forState:UIControlStateNormal];
    }
}


- (void)initViewWithKey:(NSString*)key filter:(NSDictionary*)filter
{
    if ([key isEqualToString:PARA_FILE_TYPE]) {
        NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
        for (int i =0; i <= array.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:FILE_TYPE_OFFSET + i];
            NSString* value = [filter objectForKey:key];
            if (i == 0) {
                [btn setSelected:NO];
                continue;
            }
            [btn setSelected:([value isEqualToString:(NSString*)[array objectAtIndex:(i-1)]])];
        }
    }
    if ([key isEqualToString:PARA_IMAGE_COLOR]) {
        NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
        for (int i =0; i <= array.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:IMAGE_COLOR_OFFSET + i];
            NSString* value = [filter objectForKey:key];
            if (i == 0) {
                [btn setSelected:NO];
                continue;
            }
            [btn setSelected:([value isEqualToString:(NSString*)[array objectAtIndex:(i-1)]])];
        }
    }
    if ([key isEqualToString:PARA_IMAGE_GRAY]) {
        NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
        for (int i =0; i <= array.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:IMAGE_GRAY_OFFSET + i];
            NSString* value = [filter objectForKey:key];
            if (i == 0) {
                [btn setSelected:NO];
                continue;
            }
            [btn setSelected:([value isEqualToString:(NSString*)[array objectAtIndex:(i-1)]])];
        }
    }
    if ([key isEqualToString:PARA_IMAGE_SIZE]) {
        NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
        for (int i =0; i <= array.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:IMAGE_SIZE_OFFSET + i];
            NSString* value = [filter objectForKey:key];
            if (i == 0) {
                [btn setSelected:NO];
                continue;
            }
            [btn setSelected:([value isEqualToString:(NSString*)[array objectAtIndex:(i-1)]])];
        }
    }
    if ([key isEqualToString:PARA_IMAGE_TYPE]) {
        NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
        for (int i =0; i <= array.count; i ++) {
            UIButton* btn = (UIButton*)[self viewWithTag:IMAGE_TYPE_OFFSET + i];
            NSString* value = [filter objectForKey:key];
            if (i == 0) {
                [btn setSelected:NO];
                continue;
            }
            [btn setSelected:([value isEqualToString:(NSString*)[array objectAtIndex:(i-1)]])];
        }
    }
}

- (int)getOffsetByTag:(int)tag
{
    int result = tag;
    while ([self viewWithTag:result] != nil) {
        result--;
    }
    return result+1;
}

- (IBAction)clickFilterBtn:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    int offset = [self getOffsetByTag:btn.tag];
    
    NSString* key = [self getKeyByOffset:offset];
    NSArray* array = [CommonSearchImageFilterView valueArrayForKey:key];
    
    for (int i = offset; i <= array.count+offset; i ++) {
        UIButton* button = (UIButton*)[self viewWithTag:i];
        [button setSelected:(i==btn.tag)];
    }
    
    if (_filter != nil) {
        if (btn.tag == offset) {
            [_filter removeObjectForKey:key];
            PPDebug(@"<clickFilterBtn> remove object for key %@", key);
        } else {
            NSString* value = [array objectAtIndex:btn.tag-offset-1];
            if (value) [_filter setObject:value forKey:key];
            PPDebug(@"<clickFilterBtn> did select %@ for key %@",value, key);
        }
        
    }
    
    
    
    
}

- (IBAction)clickConfirmBtn:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didConfirmFilter:)]) {
        [_delegate didConfirmFilter:self.filter];
    }
    [self disappear];
}

- (IBAction)clickCancelBtn:(id)sender
{
    [self disappear];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 
}
*/

@end
