#import "JFFAlertView.h"

#import "JFFBaseAlertView.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

#import "JFFAlertViewQueue.h"

static JFFAlertViewComparator unique_comparator_ = nil;

@interface JFFAlertView () < UIAlertViewDelegate, JFFBaseAlertView >

@property ( nonatomic, strong ) UIAlertView* alertView;
@property ( nonatomic, strong ) NSMutableArray* alertButtons;
@property ( nonatomic, assign ) BOOL dismissing;

-(void)forceShow;

@end

@implementation JFFAlertView

@synthesize alertView;
@synthesize alertButtons;
@synthesize didPresentHandler;

@dynamic title;
@dynamic message;
@dynamic alertViewStyle;

+(JFFAlertViewQueue*)sharedQueue
{
   static JFFAlertViewQueue* queue_ = nil;
   if ( !queue_ )
   {
      queue_ = [ JFFAlertViewQueue new ];
   }
   return queue_;
}

-(void)dealloc
{
   self.alertView.delegate = nil;
}

-(void)handleButtonWithIndex:( NSInteger )button_index_
{
   JFFAlertButton* alert_button_ = [ self.alertButtons objectAtIndex: button_index_ ];
   if ( alert_button_ )
      alert_button_.action( self );
}

-(void)dismissWithClickedButtonIndex:( NSInteger )button_index_ animated:( BOOL )animated_
{
   BOOL is_visible_ = self.alertView.isVisible;
   [ self.alertView dismissWithClickedButtonIndex: button_index_ animated: NO ];
   if ( !is_visible_ )
   {
      [ self alertView: self.alertView didDismissWithButtonIndex: button_index_ ];
   }
   
   if ( button_index_ != -1 )
   {
      [ self handleButtonWithIndex: button_index_ ];
   }
}

-(void)forceDismiss
{
   [ self dismissWithClickedButtonIndex: self.alertView.cancelButtonIndex animated: NO ];
}

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_
{
   JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: title_
                                                message: description_
                                      cancelButtonTitle: NSLocalizedString( @"OK", nil )
                                      otherButtonTitles: nil ];

   [ alert_ show ];
}

-(instancetype)initWithTitle:( NSString* )title_
                     message:( NSString* )message_
           cancelButtonTitle:( NSString* )cancel_button_title_
      otherButtonTitlesArray:( NSArray* )other_button_titles_
{
   self = [ super init ];
   if ( !self )
      return nil;

   //Required for alertViewShouldEnableFirstOtherButton
   NSUInteger other_buttons_count_ = [ other_button_titles_ count ];
   NSString* first_other_button_ = other_buttons_count_ > 0
      ? [ other_button_titles_ objectAtIndex: 0 ]
      : nil;

   other_button_titles_ = other_buttons_count_ > 1
      ? [ other_button_titles_ subarrayWithRange: NSMakeRange( 1, other_buttons_count_ - 1 ) ]
      : nil;

   self.alertView = [ [ UIAlertView alloc ] initWithTitle: title_
                                                  message: message_ 
                                                 delegate: self
                                        cancelButtonTitle: cancel_button_title_
                                        otherButtonTitles: first_other_button_, nil ];

   for ( NSString* button_title_ in other_button_titles_ )
   {
      [ self.alertView addButtonWithTitle: button_title_ ];
   }

   return self;
}

-(NSInteger)addAlertButtonWithIndex:( id )button_
{
   JFFAlertButton* alert_button_ = [ button_ toAlertButton ];
   NSInteger index_ = [ self.alertView addButtonWithTitle: alert_button_.title ];
   [ self.alertButtons insertObject: alert_button_ atIndex: index_ ];
   return index_;
}

-(void)addAlertButton:( id )button_
{
   [ self addAlertButtonWithIndex: button_ ];
}

-(void)addAlertButtonWithTitle:( NSString* )title_ action:( JFFAlertBlock )action_
{
   [ self addAlertButton: [ JFFAlertButton alertButton: title_ action: action_ ] ];
}

-(NSInteger)addButtonWithTitle:( NSString* )title_
{
   return [ self addAlertButtonWithIndex: title_ ];
}

+(instancetype)alertWithTitle:( NSString* )title_
                      message:( NSString* )message_
            cancelButtonTitle:( id )cancel_button_title_
            otherButtonTitles:( id )other_button_titles_, ...
{
   NSMutableArray* other_alert_buttons_ = [ NSMutableArray array ];
   NSMutableArray* other_alert_string_titles_ = [ NSMutableArray array ];

   va_list args;
   va_start( args, other_button_titles_ );
   for ( NSString* button_title_ = other_button_titles_; button_title_ != nil; button_title_ = va_arg( args, NSString* ) )
   {
      JFFAlertButton* alert_button_ = [ button_title_ toAlertButton ];
      [ other_alert_buttons_ addObject: alert_button_ ];
      [ other_alert_string_titles_ addObject: alert_button_.title ];
   }
   va_end( args );

   JFFAlertButton* cancel_button_ = [ cancel_button_title_ toAlertButton ];
   if ( cancel_button_ )
   {
      [ other_alert_buttons_ insertObject: cancel_button_ atIndex: 0 ];
   }

   JFFAlertView* alert_view_ = [ [ self alloc ] initWithTitle: title_
                                                       message: message_
                                             cancelButtonTitle: cancel_button_.title
                                        otherButtonTitlesArray: other_alert_string_titles_ ];

   alert_view_.alertButtons = other_alert_buttons_;

   return alert_view_;
}

+(void)setUniqueComparator:( JFFAlertViewComparator )comparator_
{
   unique_comparator_ = [ comparator_ copy ];
}

-(void)show
{
   [ [ [ self class ] sharedQueue ] showOrAddAlert: self
                                      showCallback:
    ^( id< JFFBaseAlertView > alert_view_ )
    {
       [ ( JFFAlertView* )alert_view_ forceShow ];
    }
                                        comparator: unique_comparator_ ];
}

-(void)forceShow
{
   [ self.alertView show ];
}

-(NSString*)description
{
   return [ NSString stringWithFormat: @"<%@: %p> title: %@, message: %@"
           , [ self class ]
           , self
           , self.title
           , self.message ];
}

-(BOOL)isEqual:( id )other_
{
   if ( [ other_ class ] != [ self class ] )
      return NO;

   return [ self isEqualToAlertView: other_ ];
}

-(BOOL)isEqualToAlertView:( JFFAlertView* )other_alert_view_
{
   BOOL equal_title_ = ( self.title.length == 0 && other_alert_view_.title.length == 0 )
      || ( [ self.title isEqualToString: other_alert_view_.title ] );

   BOOL equal_message_ = ( self.message.length == 0 && other_alert_view_.message.length == 0 )
      || ( [ self.message isEqualToString: other_alert_view_.message ] );

   return equal_title_ && equal_message_;
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alert_view_ clickedButtonAtIndex:( NSInteger )button_index_
{
   [ self handleButtonWithIndex: button_index_ ];
}

-(void)didPresentAlertView:( UIAlertView* )alertView_
{
   if ( self.didPresentHandler )
      self.didPresentHandler( self );
}

-(void)alertView:( UIAlertView* )alert_view_ didDismissWithButtonIndex:( NSInteger )index_
{
   JFFAlertViewQueue* queue_ = [ [ self class ] sharedQueue ];
   [ queue_ removeAlert: self ];
   [ queue_ showTopAlertView ];
}

-(void)alertView:( UIAlertView* )alert_view_ willDismissWithButtonIndex:( NSInteger )index_
{
   self.dismissing = YES;
}

-(void)willPresentAlertView:( UIAlertView * )alert_view_
{
   self.dismissing = NO;
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView*)alert_view_
{
   if ( alert_view_.alertViewStyle != UIAlertViewStyleDefault )
   {
      NSString* text_ = [ [ alert_view_ textFieldAtIndex: 0 ] text ];
      return [ text_ length ] > 0;
   }

   return YES;
}

-(UITextField*)textFieldAtIndex:( NSInteger )index_
{
   return [ self.alertView textFieldAtIndex: index_ ];
}

-(id)forwardingTargetForSelector:( SEL )selector_
{
   if ( [ self.alertView respondsToSelector: selector_ ] )
      return self.alertView;

   return [ super forwardingTargetForSelector: selector_ ];
}
@end
