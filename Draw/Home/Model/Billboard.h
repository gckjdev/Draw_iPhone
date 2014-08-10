//
//  Billboard.h
//  Draw
//
//  Created by ChaoSo on 14-7-16.
//
//

/*
 
 {
 "index" : 4,
 "function" : "goToGuidePage",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : []
 },
 
 {
 "index" : 1,
 "function" : "enterLearnDrawTutorialId:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : ["tutorialId-2"]
 },
 {
 "index" : 2,
 "function" : "enterHotByOpusClass:",
 "imageId" : "image2",
 "image" : "http://58.215.160.100:8080/app_res/tutorial/image/title-7.png",
 "text" : "",
 "parameters" : ["2006"]
 },
 {
 "index" : 3,
 "function" : "openWebURL:title:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : ["http://www.xiaoji.fm/m", "Hello, Littlegee"]
 },
 {
 "index" : 5,
 "function" : "enterShopWithItemId:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : [""]
 },
 {
 "index" : 6,
 "function" : "enterContestWithContestId:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : ["53dd0e21e4b018a896adce94"]
 },
 {
 "index" : 7,
 "function" : "enterContestWithContestId:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : ["53dd0e21e4b018a896adce94"]
 },
 {
 "index" : 8,
 "function" : "enterContestWithContestId:",
 "imageId" : "image1",
 "image" : "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg",
 "text" : "",
 "parameters" : ["53dd0e21e4b018a896adce94"]
 }
 
 */

#import <Foundation/Foundation.h>

@interface Billboard : NSObject

+ (id) objectWithDictionary:(NSDictionary*)dictionary;
- (id) initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, retain) NSDictionary* dataDict;

- (int)index;
- (NSString*)image;
- (NSString*)imageId;
- (NSString*)function;

- (void)clickAction:(PPViewController*) pc;

@end
