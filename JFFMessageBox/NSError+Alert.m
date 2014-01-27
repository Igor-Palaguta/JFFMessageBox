#import "NSError+Alert.h"

#import "JFFAlertView.h"

@implementation NSError (Alert)

-(void)printToLog
{
   NSLog( @"NSError : %@, domain : %@ code : %d", [ self localizedDescription ], [ self domain ], [ self code ] );
}

-(void)showAlertWithTitle:( NSString* )title_
{
   [ self printToLog ];
   [ JFFAlertView showAlertWithTitle: title_ description: [ self localizedDescription ] ];
}

@end
