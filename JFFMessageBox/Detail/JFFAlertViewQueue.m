#import "JFFAlertViewQueue.h"

#import "JFFBaseAlertView.h"

@interface JFFAlertViewContext : NSObject

@property ( nonatomic, strong ) id< JFFBaseAlertView > alertView;
@property ( nonatomic, copy ) JFFAlertViewShowCallback showCallback;

+(id)contextWithAlertView:( id< JFFBaseAlertView > )alert_view_
             showCallback:( JFFAlertViewShowCallback )show_callback_;

@end


@implementation JFFAlertViewContext

@synthesize alertView;
@synthesize showCallback;

+(id)contextWithAlertView:( id< JFFBaseAlertView > )alert_view_
             showCallback:( JFFAlertViewShowCallback )show_callback_
{
   JFFAlertViewContext* context_ = [ self new ];
   context_.alertView = alert_view_;
   context_.showCallback = show_callback_;
   return context_;
}

@end

@interface JFFAlertViewQueue ()

@property ( nonatomic, strong ) NSMutableArray* queue;

@end

@implementation JFFAlertViewQueue

@synthesize queue = _queue;

-(void)dealloc
{
   [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}

-(instancetype)init
{
   self = [ super init ];
   if ( self )
   {
      [ [ NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector( handleBackground: )
                                                     name: UIApplicationWillResignActiveNotification 
                                                   object: nil ];
   }
   return self;
}

-(NSMutableArray*)queue
{
   if ( !_queue )
   {
      _queue = [ [ NSMutableArray alloc ] init ];
   }
   return _queue;
}

-(BOOL)shouldIgnoreAlertView:( id< JFFBaseAlertView > )alert_view_
                  comparator:( JFFAlertViewComparator )comparator_
{
   if ( !comparator_ )
      return NO;

   for ( JFFAlertViewContext* context_ in self.queue )
   {
      if ( comparator_( alert_view_, context_.alertView ) )
      {
         NSLog(@"ignore alert view: %@", alert_view_);
         return YES;
      }
   }

   return NO;
}

-(BOOL)addAlert:( id< JFFBaseAlertView > )alert_view_
   showCallback:( JFFAlertViewShowCallback )show_callback_
     comparator:( JFFAlertViewComparator )comparator_
{
   BOOL should_show_alert_ = ![ self shouldIgnoreAlertView: alert_view_ comparator: comparator_ ];

   if ( should_show_alert_ )
   {
      [ self.queue addObject: [ JFFAlertViewContext contextWithAlertView: alert_view_
                                                            showCallback: show_callback_ ] ];
   }

   return should_show_alert_;
}

-(void)showOrAddAlert:( id< JFFBaseAlertView > )alert_view_
         showCallback:( JFFAlertViewShowCallback )show_callback_
           comparator:( JFFAlertViewComparator )comparator_
{
   BOOL did_add_alert_ = [ self addAlert: alert_view_
                            showCallback: show_callback_
                              comparator: comparator_ ];

   if ( did_add_alert_ && [ self count ] == 1 )
   {
      [ self showTopAlertView ];
   }
}

-(void)removeAlert:( id< JFFBaseAlertView > )alert_view_
{
   for ( JFFAlertViewContext* context_ in self.queue )
   {
      if ( context_.alertView == alert_view_ )
      {
         [ self.queue removeObject: context_ ];
         break;
      }
   }
}

-(void)dismissAll
{
   NSArray* temporary_active_contexts_ = [ [ NSArray alloc ] initWithArray: self.queue ];
   //Should be nil
   self.queue = nil;

   for ( JFFAlertViewContext* context_ in temporary_active_contexts_ )
   {
      [ context_.alertView forceDismiss ];
   }
}

-(void)handleBackground:( NSNotification* )notification_
{
   [ self dismissAll ];
}

-(JFFAlertViewContext*)topAlertView
{
   if ( [ self.queue count ] == 0 )
      return nil;

   return [ self.queue objectAtIndex: 0 ];
}

-(void)showTopAlertView
{
   JFFAlertViewContext* context_ = [ self topAlertView ];
   if ( context_.showCallback )
   {
      context_.showCallback( context_.alertView );
   }
}

-(NSUInteger)count
{
   return [ self.queue count ];
}

@end
