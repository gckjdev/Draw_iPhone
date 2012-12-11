//
//  DrawHomeViewController.h
//  Draw
//
//  Created by gamy on 12-12-10.
//
//

#import "SuperHomeController.h"
#import "RouterService.h"
#import "DrawDataService.h"
#import "DrawGameService.h"
#import "OfflineGuessDrawController.h"

@interface DrawHomeViewController : SuperHomeController<RouterServiceDelegate, DrawDataServiceDelegate, DrawGameServiceDelegate>
{
    
}
+ (id)defaultInstance;
@end
