#import "JFFActionSheet.h"

#import "JFFBaseAlertView.h"
#import "JFFAlertViewQueue.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

@interface JFFActionSheet () < UIActionSheetDelegate, JFFBaseAlertView >

@property ( nonatomic, strong ) UIActionSheet* actionSheet;
@property ( nonatomic, strong ) NSMutableArray* alertButtons;
@property ( nonatomic, strong ) JFFAlertButton* cancelButton;
@property ( nonatomic, assign ) BOOL dismissing;

@end

@implementation JFFActionSheet

@synthesize actionSheet;
@synthesize alertButtons;
@synthesize cancelButton;

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
   self.actionSheet.delegate = nil;
}

-(instancetype)initWithTitle:( NSString* )title_
           cancelButtonTitle:( NSString* )cancel_button_title_
      destructiveButtonTitle:( NSString* )destructive_button_title_
      otherButtonTitlesArray:( NSArray* )other_button_titles_
{
   self = [ super init ];
   if ( !self )
      return nil;

   self.actionSheet = [ [ UIActionSheet alloc ] initWithTitle: title_
                                                     delegate: self
                                            cancelButtonTitle: nil
                                       destructiveButtonTitle: destructive_button_title_
                                            otherButtonTitles: nil ];

   for ( NSString* button_title_ in other_button_titles_ )
   {
      [ self.actionSheet addButtonWithTitle: button_title_ ];
   }

   if ( cancel_button_title_ )
   {
      [ self.actionSheet addButtonWithTitle: cancel_button_title_ ];
   }

   return self;
}

-(NSInteger)addActionButtonWithIndex:( id )alert_button_id_
{
   JFFAlertButton* alert_button_ = [ alert_button_id_ toAlertButton ];
   NSInteger index_ = [ self.actionSheet addButtonWithTitle: alert_button_.title ];
   [ self.alertButtons insertObject: alert_button_ atIndex: index_ ];
   return index_;
}

-(void)addActionButton:( id )alert_button_
{
   [ self addActionButtonWithIndex: alert_button_ ];
}

-(void)addActionButtonWithTitle:( NSString* )title_ action:( JFFAlertBlock )action_
{
   [ self addActionButton: [ JFFAlertButton alertButton: title_ action: action_ ] ];
}

-(NSInteger)addButtonWithTitle:( NSString* )title_
{
   return [ self addActionButtonWithIndex: title_ ];
}

+(instancetype)actionSheetWithTitle:( NSString* )title_
                  cancelButtonTitle:( id )cancel_button_title_
             destructiveButtonTitle:( id )destructive_button_title_
                  otherButtonsArray:( NSArray* )other_buttons_
{
   NSMutableArray* other_action_buttons_ = [ NSMutableArray array ];
   NSMutableArray* other_action_string_titles_ = [ NSMutableArray array ];
   
   JFFAlertButton* destructive_button_ = nil;
   if ( destructive_button_title_ )
   {
      destructive_button_ = [ destructive_button_title_ toAlertButton ];
      [ other_action_buttons_ insertObject: destructive_button_ atIndex: 0 ];
   }

   for ( id button_ in other_buttons_ )
   {
      JFFAlertButton* alert_button_ = [ button_ toAlertButton ];
      [ other_action_buttons_ addObject: alert_button_ ];
      [ other_action_string_titles_ addObject: alert_button_.title ];
   }

   JFFActionSheet* action_sheet_ = [ [ self alloc ] initWithTitle: title_
                                                cancelButtonTitle: cancel_button_title_
                                           destructiveButtonTitle: destructive_button_.title
                                           otherButtonTitlesArray: other_action_string_titles_ ];
   
   JFFAlertButton* cancel_button_ = [ cancel_button_title_ toAlertButton ];
   
   if ( cancel_button_ )
   {
      [ other_action_buttons_ addObject: cancel_button_ ];
      action_sheet_.actionSheet.cancelButtonIndex = action_sheet_.actionSheet.numberOfButtons - 1;
   }
   
   action_sheet_.alertButtons = other_action_buttons_;
   
   return action_sheet_;
}

+(instancetype)actionSheetWithTitle:( NSString* )title_
                  cancelButtonTitle:( id )cancel_button_title_
             destructiveButtonTitle:( id )destructive_button_title_
                  otherButtonTitles:( id )other_titles_, ...
{
   NSMutableArray* other_buttons_ = [ NSMutableArray array ];
   va_list args;
   va_start( args, other_titles_ );
   for ( id button_ = other_titles_; button_ != nil; button_ = va_arg( args, id ) )
   {
      [ other_buttons_ addObject: button_ ];
   }
   va_end( args );

   return [ self actionSheetWithTitle: title_
                    cancelButtonTitle: cancel_button_title_
               destructiveButtonTitle: destructive_button_title_
                    otherButtonsArray: other_buttons_ ];
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:( UIActionSheet* )action_sheet_ clickedButtonAtIndex:( NSInteger )button_index_
{
   //Close without any select
   if ( button_index_ == -1 )
      return;

   JFFAlertButton* alert_button_ = [ self.alertButtons objectAtIndex: button_index_ ];
   if ( alert_button_ )
      alert_button_.action( self );
}

-(void)willPresentActionSheet:( UIActionSheet* )action_sheet_
{
   self.dismissing = NO;
}

-(void)actionSheet:( UIActionSheet* )action_sheet_ willDismissWithButtonIndex:( NSInteger )button_index_
{
   self.dismissing = YES;
}

-(void)actionSheet:( UIActionSheet* )action_sheet_ didDismissWithButtonIndex:( NSInteger )button_index_
{
   JFFAlertViewQueue* queue_ = [ [ self class ] sharedQueue ];

   [ queue_ removeAlert: self ];
   [ queue_ showTopAlertView ];
}

-(void)dismissWithClickedButtonIndex:( NSInteger )button_index_ animated:( BOOL )animated_
{
   BOOL is_visible_ = self.actionSheet.isVisible;
   [ self.actionSheet dismissWithClickedButtonIndex: button_index_ animated: NO ];
   if ( !is_visible_ )
   {
      [ self actionSheet: self.actionSheet didDismissWithButtonIndex: button_index_ ];
   }
}

-(void)forceDismiss
{
   [ self dismissWithClickedButtonIndex: self.actionSheet.cancelButtonIndex animated: NO ];
}

-(void)showFromBarButtonItem:( UIBarButtonItem* )item_ animated:( BOOL )animated_
{
   [ [ [ self class ] sharedQueue ] showOrAddAlert: self
                                      showCallback:
    ^( id< JFFBaseAlertView > alert_view_ )
    {
       JFFActionSheet* action_sheet_ = ( JFFActionSheet* )alert_view_;
       
       [ action_sheet_.actionSheet showFromBarButtonItem: item_ animated: animated_ ];
    }
                                        comparator: nil ];
}

-(void)showInView:( UIView* )view_
{
   [ [ [ self class ] sharedQueue ] showOrAddAlert: self
                                      showCallback:
    ^( id< JFFBaseAlertView > alert_view_ )
    {
       JFFActionSheet* action_sheet_ = ( JFFActionSheet* )alert_view_;
       
       [ action_sheet_.actionSheet showInView: view_ ];
    }
    comparator: nil ];
}

-(void)uniqueShowFromBarButtonItem:( UIBarButtonItem* )item_ animated:( BOOL )animated_
{
   if ( [ [ [ self class ] sharedQueue ] count ] == 0 )
   {
      [ self showFromBarButtonItem: item_ animated: animated_ ];
   }
}

-(UIActionSheetStyle)actionSheetStyle
{
   return self.actionSheet.actionSheetStyle;
}

-(void)setActionSheetStyle:( UIActionSheetStyle )style_
{
   self.actionSheet.actionSheetStyle = style_;
}

@end
