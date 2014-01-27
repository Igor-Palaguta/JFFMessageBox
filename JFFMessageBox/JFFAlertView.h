#include "JFFAlertBlock.h"
#include "JFFAlertViewComparator.h"

#import <UIKit/UIKit.h>

@class JFFAlertView;

@interface JFFAlertView : NSObject

@property ( nonatomic, copy ) NSString* title;
@property ( nonatomic, copy ) NSString* message;

@property ( nonatomic, copy ) JFFAlertBlock didPresentHandler;
@property ( nonatomic, assign ) UIAlertViewStyle alertViewStyle;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(instancetype)alertWithTitle:( NSString* )title_
                      message:( NSString* )message_
            cancelButtonTitle:( id )cancel_button_title_
            otherButtonTitles:( id )other_button_titles_, ...;

+(void)setUniqueComparator:( JFFAlertViewComparator )comparator_;

//pass NSString(button title) or JFFAlertButton
-(void)addAlertButton:( id )alert_button_;
-(void)addAlertButtonWithTitle:( NSString* )title_ action:( JFFAlertBlock )action_;

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_;

-(void)show;

-(UITextField*)textFieldAtIndex:( NSInteger )index_;

-(BOOL)isEqualToAlertView:( JFFAlertView* )other_alert_view_;

@end
