#import "JFFAlertButton.h"

@implementation JFFAlertButton

@synthesize title;
@synthesize action;

-(instancetype)initButton:( NSString* )title_
                   action:( JFFAlertBlock )action_
{
   self = [ super init ];

   if ( self )
   {
      self.title = title_;
      self.action = action_;
   }

   return self;
}

+(instancetype)alertButton:( NSString* )title_ action:( JFFAlertBlock )action_
{
   return [ [ self alloc ] initButton: title_ action: action_ ];
}

-(NSString*)description
{
   return self.title;
}

@end
