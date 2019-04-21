#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>

@interface MediaControlsHeaderView : UIView

@property (nonatomic,retain) UIButton * routingButton; 

@end

@interface MediaControlsPanelViewController : UIViewController

@property (nonatomic,retain) MediaControlsHeaderView * headerView;
+(id)panelViewControllerForCoverSheet;
-(NSInteger)style;
-(void)setStyle:(NSInteger)arg1 ;

@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 ;
@end

@interface SBFluidSwitcherViewController : UIViewController

@property (nonatomic, retain) MediaControlsPanelViewController *testMCPVC;
@property (nonatomic, retain) UIScrollView *scrollView;

@end

@interface SBReachabilityWindow : UIWindow

@property (nonatomic, retain) MediaControlsPanelViewController *testMCPVC;
@property (nonatomic, retain) UIView *lastSeen;

@end

@interface SBReachabilityBackgroundViewController : UIViewController

@end

@interface SBReachabilityManager : NSObject

+ (id)sharedInstance;
@property(readonly, nonatomic) _Bool reachabilityModeActive; // @synthesize reachabilityModeActive=_reachabilityModeActive;
@property(readonly, nonatomic) double effectiveReachabilityYOffset; // @synthesize effectiveReachabilityYOffset=_effectiveReachabilityYOffset;

@end