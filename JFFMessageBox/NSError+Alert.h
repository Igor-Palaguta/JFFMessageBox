#import <Foundation/Foundation.h>

typedef BOOL (^JFFAlertViewErrorHandler)( NSString* title_, NSError* error_ );

@interface NSError (Alert)

+(void)addErrorHandler:( JFFAlertViewErrorHandler )handler_;

-(void)showAlertWithTitle:( NSString* )title_;

@end
