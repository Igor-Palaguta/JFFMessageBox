#import "NSError+Alert.h"

#import "JFFAlertView.h"

static NSMutableArray* error_handlers_ = nil;

@implementation NSError (Alert)

+(void)addErrorHandler:( JFFAlertViewErrorHandler )handler_
{
   JFFAlertViewErrorHandler handler_copy_ = [ handler_ copy ];
   if ( !error_handlers_ )
   {
      error_handlers_ = [ NSMutableArray arrayWithObject: handler_copy_ ];
   }
   else
   {
      [ error_handlers_ addObject: handler_copy_ ];
   }
}

-(void)showAlertWithTitle:( NSString* )title_
{
   for ( JFFAlertViewErrorHandler handler_ in error_handlers_ )
   {
      if ( handler_( title_, self ) )
         return;
   }

   [ JFFAlertView showAlertWithTitle: title_ description: [ self localizedDescription ] ];
}

@end
