#import "JFFAlertBlock.h"

#import <UIKit/UIKit.h>

@interface JFFActionSheet : NSObject

@property ( nonatomic, assign ) UIActionSheetStyle actionSheetStyle;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(instancetype)actionSheetWithTitle:( NSString* )title_
                  cancelButtonTitle:( id )cancel_button_title_
             destructiveButtonTitle:( id )destructive_button_title_
                  otherButtonTitles:( id )other_button_titles_, ...;

+(instancetype)actionSheetWithTitle:( NSString* )title_
                  cancelButtonTitle:( id )cancel_button_title_
             destructiveButtonTitle:( id )destructive_button_title_
                  otherButtonsArray:( NSArray* )other_buttons_;

//pass NSString(button title) or JFFAlertButton
//-(void)addActionButton:( id )action_button_;

//-(void)addActionButtonWithTitle:( NSString* )title_ action:( JFFAlertBlock )action_;

-(void)showFromBarButtonItem:( UIBarButtonItem* )item_ animated:( BOOL )animated_;
-(void)uniqueShowFromBarButtonItem:( UIBarButtonItem* )item_ animated:( BOOL )animated_;

-(void)showInView:( UIView* )view_;

-(void)forceDismiss;

@end
