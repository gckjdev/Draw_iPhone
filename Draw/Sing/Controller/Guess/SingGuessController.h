//
//  SingGuessController.h
//  Draw
//
//  Created by 王 小涛 on 13-6-24.
//
//

#import "CommonGuessController.h"
#import "OpusService.h"

@interface SingGuessController : CommonGuessController <OpusServiceDelegate>
@property (retain, nonatomic) IBOutlet UIButton *opusButton;

@end
