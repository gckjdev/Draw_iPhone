//
//  GroupPermission.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "CommonService.h"

typedef enum{
    GroupRoleAdmin = 1,
    GroupRoleUser = 2,
    GroupRoleGuest = 3,
    GroupRoleCreator = 4,
}GroupRole;

@interface GroupPermission : CommonService

@end
