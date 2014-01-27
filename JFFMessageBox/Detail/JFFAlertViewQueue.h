#import "../JFFAlertViewComparator.h"

#import <UIKit/UIKit.h>

@protocol JFFBaseAlertView;

typedef void (^JFFAlertViewShowCallback)( id< JFFBaseAlertView > );

@interface JFFAlertViewQueue : NSObject

-(void)showOrAddAlert:( id< JFFBaseAlertView > )alert_view_
         showCallback:( JFFAlertViewShowCallback )show_callback_
           comparator:( JFFAlertViewComparator )comparator_;

-(void)removeAlert:( id< JFFBaseAlertView > )alert_view_;
-(void)dismissAll;

-(void)showTopAlertView;

-(NSUInteger)count;

@end
