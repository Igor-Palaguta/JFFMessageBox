#import "JFFAlertBlock.h"

#import <Foundation/Foundation.h>

@interface JFFAlertButton : NSObject

@property ( nonatomic, strong ) NSString* title;
@property ( nonatomic, copy ) JFFAlertBlock action;

+(instancetype)alertButton:( NSString* )title_ action:( JFFAlertBlock )action_;

@end
