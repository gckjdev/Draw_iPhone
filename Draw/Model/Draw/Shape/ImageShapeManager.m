//
//  ImageShapeManager.m
//  Draw
//
//  Created by gamy on 13-6-7.
//
//

#import "ImageShapeManager.h"
#import "PocketSVG.h"
#import "Draw.pb.h"
#import "ItemType.h"
#import "ShapeGroup.h"
#import "PPSmartUpdateData.h"
#import "PPConfigManager.h"
#import "DrawUtils.h"
#import "UIBezierPath+Ext.h"
#import "UserGameItemManager.h"
#import "FileUtil.h"

#define IMAGE_SHAPE_ZIP_NAME @"image_shape.zip"
#define IMAGE_SHAPE_META_FILE @"meta.pb"
#define SUFFIX @".svg"


@interface ShapeSmartData : PPSmartUpdateData

@end

@implementation ShapeSmartData

- (BOOL)isDataExist
{
    if ([super isDataExist] == NO){
        return NO;
    }
    
    NSString* dirPath = [PPSmartUpdateDataUtils pathBySubDir:self.localSubDir name:self.name type:self.type];
    NSString *filePath = [dirPath stringByAppendingPathComponent:IMAGE_SHAPE_META_FILE];
    if ([FileUtil isPathExist:filePath]){
        return YES;
    }
    else{
        return NO;
    }
}

@end

@interface ImageShapeManager()
{
    NSMutableDictionary *_bezierPathDict;
    ShapeSmartData *_smartData;
    NSArray *_imageShapeGroupList;
    
}

@property (nonatomic, retain) NSArray* imageShapeGroupList;

@end



@implementation ImageShapeManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ImageShapeManager)

- (id)init
{
    self = [super init];
    if (self) {
        
        _smartData = [[ShapeSmartData alloc] initWithName:IMAGE_SHAPE_ZIP_NAME
                                                        type:SMART_UPDATE_DATA_TYPE_ZIP
                                                  bundlePath:IMAGE_SHAPE_ZIP_NAME
                                             initDataVersion:[PPConfigManager currentImageShapeVersion]];
        
        [self updateImageShapeList];
        
        __block ImageShapeManager *pt = self;
        
        [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            if (!isAlreadyExisted) {
                [pt updateImageShapeList];
            }
            PPDebug(@"checkUpdateAndDownload successfully");
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
        
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_smartData);
    PPRelease(_imageShapeGroupList);
    PPRelease(_bezierPathDict);
    [super dealloc];
}

- (void)updateImageShapeList
{
    NSString *filePath = [[_smartData currentDataPath] stringByAppendingPathComponent:IMAGE_SHAPE_META_FILE];
    @try {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSArray* list = [[PBImageShapeGroupMeta parseFromData:data] imageShapeGroup];
            if ([list count] > 0){
                self.imageShapeGroupList = list;
            }
        }
    }
    @catch (NSException *exception) {
        PPDebug(@"<updateImageShapeList>Fail to parse draw bg data");
    }
}




- (NSString *)baseDir
{
    return [_smartData currentDataPath];
}

- (NSArray *)pbImageShapeGroupList
{
    UserGameItemManager *ugManager = [UserGameItemManager defaultManager];
    NSArray *ret = [_imageShapeGroupList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PBImageShapeGroup *sg1 = obj1;
        PBImageShapeGroup *sg2 = obj2;
        BOOL has1 = [ugManager hasItem:sg1.groupId];
        BOOL has2 = [ugManager hasItem:sg2.groupId];
        if (has1 ^ has2) {
            return has2?NSOrderedDescending:NSOrderedAscending;
        }else{
            return sg1.groupId>sg2.groupId?NSOrderedDescending:NSOrderedAscending;
        }
    }];
    return ret;
}

- (NSString *)fullPathWithShapeType:(ShapeType)type
{
    NSString *name = [NSString stringWithFormat:@"%d%@",type,SUFFIX];
    NSString *filePath = [[self baseDir] stringByAppendingPathComponent:name];
    return filePath;
}

- (ImageShapeInfo *)imageShapeWithType:(ShapeType)type
{
    UIBezierPath *bPath = [self pathWithType:type];
    if (bPath) {
        ImageShapeInfo *shapeInfo = [[[ImageShapeInfo alloc] initWithCGPath:bPath.CGPath] autorelease];
        shapeInfo.type = type;
        return shapeInfo;
    }
    return nil;
}


- (BOOL)isBasicShapeType:(ShapeType)type
{
    if (type >= ShapeTypeImageBasicStart && type < ShapeTypeImageBasicEnd) {
        return YES;
    }
    return NO;
}


- (UIBezierPath *)pathWithBasicType:(ShapeType)type
                         startPoint:(CGPoint)startPoint
                           endPoint:(CGPoint)endPoint
{
    
    CGRect rect = CGRectWithPoints(startPoint, endPoint);
    switch (type) {
        case ShapeTypeBeeline:
            return [UIBezierPath bezierPathWithLineFromStartPoint:startPoint endPoint:endPoint];
        case ShapeTypeRectangle:
            return [UIBezierPath bezierPathWithRect:rect];
        case ShapeTypeTriangle:
            return [UIBezierPath bezierPathWithTriangleInRect:rect reverse:(startPoint.y > endPoint.y)];
        case ShapeTypeStar:
            return [UIBezierPath bezierPathWithFiveStartInRect:rect reverse:(startPoint.y > endPoint.y)];
        case ShapeTypeRoundRect:
            return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12];
        case ShapeTypeEllipse:
            return [UIBezierPath bezierPathWithOvalInRect:rect];
        default:
            break;
    }
    return nil;
}


- (UIBezierPath *)pathWithBasicType:(ShapeType)type
{
    CGSize size = [ImageShapeInfo defaultImageShapeSize];
    CGPoint end = CGPointMake(size.width, size.height);
    return [self pathWithBasicType:type startPoint:CGPointZero endPoint:end];
}


- (UIBezierPath *)pathWithType:(ShapeType)type
{
    if (type == ShapeTypeNone) {
        return nil;
    }
    if (_bezierPathDict == nil) {
        _bezierPathDict = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"%d",type];
    UIBezierPath *bPath = [_bezierPathDict objectForKey:key];
    if (bPath == nil) {
        if ([self isBasicShapeType:type]) {
            bPath = [self pathWithBasicType:type];
        }else{
            NSString *filePath = [self fullPathWithShapeType:type];
            if ([filePath length] != 0) {
                bPath = [PocketSVG bezierPathWithSVGFilePath:filePath];
            }
        }
        if (bPath) {
            [_bezierPathDict setObject:bPath forKey:key];
        }
    }
    return bPath;
}

- (void)cleanCache
{
    [_bezierPathDict removeAllObjects];
    PPRelease(_bezierPathDict);
}


//////////  TEST CODE //////////


+ (void)printShapeGroup:(PBImageShapeGroup *)group
{
    PPDebug(@"===PRINT GROUP START===");
    //group id
    PPDebug(@"GROUP ID = %d;\n", group.groupId);
    
    //name
    PPDebug(@"LOCALE NAME LIST = [");
    for (PBLocalizeString *lString in group.groupName) {
        PPDebug(@"%@ = %@",lString.languageCode,lString.localizedText);
    }
    PPDebug(@"];\n");
    
    //type list
//    PPDebug(@"");
    NSString *string = @"";
//    for (NSNumber *type in group.shapeType) {
    for (int i=0; i<group.shapeType.count; i++) {
        int type = [group.shapeType int32AtIndex:i];
        if ([string length] > 0) {
            string = [NSString stringWithFormat:@"%@, %d",string, type];
        }else{
            string = [NSString stringWithFormat:@"%d",type];
        }

    }
    PPDebug(@"TYPE LIST = [%@];\n",string);

    PPDebug(@"===PRINT GROUP STOP ===\n");
    
}

#define BUILD_GROUP(group)  [builder addImageShapeGroup:[[[[group##Group alloc] init] autorelease] toPBShapeGroup]];
#define PRINT_GROUP(group) [ImageShapeManager printShapeGroup:group]


+ (void)loadMetaFile
{
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/qqn_pipi/tool/image_shape/meta.pb"];
    PBImageShapeGroupMeta *meta = [PBImageShapeGroupMeta parseFromData:data];
    
    for (PBImageShapeGroup *group in meta.imageShapeGroup) {
        PRINT_GROUP(group);
    }
    
}

+ (void)createMetaFile
{
    PBImageShapeGroupMetaBuilder *builder = [[[PBImageShapeGroupMetaBuilder alloc] init] autorelease];
    
    BUILD_GROUP(Basic0)
    BUILD_GROUP(Nature0)
    BUILD_GROUP(Nature1)

    BUILD_GROUP(Animal0)
    BUILD_GROUP(Animal1)
    
    BUILD_GROUP(Shape0)
    BUILD_GROUP(Shape1)
    
    BUILD_GROUP(Stuff0)
    BUILD_GROUP(Stuff1)

    BUILD_GROUP(Sign0)
    BUILD_GROUP(Sign1)
    
    BUILD_GROUP(Plant0)
    BUILD_GROUP(Plant1)
    BUILD_GROUP(Plant2)
    
    NSData *data = [[builder build] data];
    [data writeToFile:@"/Users/qqn_pipi/tool/image_shape/meta.pb" atomically:YES];
}

@end
