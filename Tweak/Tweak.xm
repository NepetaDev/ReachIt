#import <Cephei/HBPreferences.h>
#import <libcolorpicker.h>
#import "Tweak.h"

HBPreferences *preferences;

BOOL dpkgInvalid = false;
BOOL enabled;
NSInteger style;

%group ReachIt

%hook SBReachabilityBackgroundView

-(void)_setupChevron { }

%end

%hook SBReachabilityManager

- (void)_panToDeactivateReachability:(id)arg1 { 
    if (![arg1 isKindOfClass:%c(SBScreenEdgePanGestureRecognizer)]) return;
    %orig;
}

- (void)_tapToDeactivateReachability:(id)arg1 { }

%end

%hook MPVolumeSlider

- (bool)isOnScreenForVolumeDisplay {
    if (!enabled) return %orig;
    return false;
}

%end

%hook SBReachabilityWindow

%property (nonatomic, retain) MediaControlsPanelViewController *testMCPVC;
%property (nonatomic, retain) UIView *lastSeen;

-(void)layoutSubviews {
    %orig;
    if (!self.testMCPVC) {
        UIView *view = self;
        view.userInteractionEnabled = YES;
        view.layer.masksToBounds = NO;
        view.clipsToBounds = NO;
        self.testMCPVC = [%c(MediaControlsPanelViewController) panelViewControllerForCoverSheet];
        [self.testMCPVC setStyle:style];
        CGFloat height = [[%c(SBReachabilityManager) sharedInstance] effectiveReachabilityYOffset];
        self.testMCPVC.view.frame = CGRectMake(view.frame.origin.x, -height, view.frame.size.width, height);
        [view addSubview:self.testMCPVC.view];
        [view bringSubviewToFront:self.testMCPVC.view];
    }

    self.testMCPVC.view.hidden = !enabled;

    if (self.testMCPVC.style != style) [self.testMCPVC setStyle:style];
}

-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 {
    if (!enabled) return %orig;
    UIView *candidate = %orig;
    
    if (arg1.y <= 0) {
        candidate = [self.testMCPVC.view hitTest:[self.testMCPVC.view convertPoint:arg1 fromView:self] withEvent:arg2];

        if (!candidate || candidate.superview == self.testMCPVC.view) {
            candidate = self.lastSeen;
            self.lastSeen = nil;
        } else {
            self.lastSeen = candidate;
        }
    }

    return candidate;
}

%end

%hook SBFluidSwitcherViewController

%property (nonatomic, retain) MediaControlsPanelViewController *testMCPVC;

-(void)viewWillAppear:(BOOL)arg1 {
    %orig;
    if (!self.testMCPVC) {
        self.testMCPVC = [%c(MediaControlsPanelViewController) panelViewControllerForCoverSheet];
        self.testMCPVC.view.alpha = 0.0;
        [self.view addSubview:self.testMCPVC.view];
    }

    self.testMCPVC.view.hidden = !enabled;
    
    if (self.testMCPVC.style != style) [self.testMCPVC setStyle:style];
}

-(void)handleReachabilityModeActivated {
    %orig;
    if (!enabled) return;

    self.testMCPVC.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);

    [self.testMCPVC setStyle:style];
    
    [UIView animateWithDuration:0.2 animations:^() {
        self.testMCPVC.view.alpha = 1.0;
    }];
}

-(void)handleReachabilityModeDeactivated {
    %orig;
    if (!enabled) return;

    self.testMCPVC.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
    [UIView animateWithDuration:0.2 animations:^() {
        self.testMCPVC.view.alpha = 0.0;
    }];
}

%end

%end

%group ReachItIntegrityFail

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    if (!dpkgInvalid) return;
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"😡😡😡"
        message:@"The build of ReachIt you're using comes from an untrusted source. Pirate repositories can distribute malware and you will get subpar user experience using any tweaks from them.\nRemember: ReachIt is free. Uninstall this build and install the proper version of ReachIt from:\nhttps://repo.nepeta.me/\n(it's free, damnit, why would you pirate that!?)"
        preferredStyle:UIAlertControllerStyleAlert
    ];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Damn!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
    }]];

    [((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}

%end

%end

%ctor {
    dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/me.nepeta.reachit.list"];

    if (dpkgInvalid) {
        %init(ReachItIntegrityFail);
        return;
    }

    preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.reachit"];

    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerInteger:&style default:1 forKey:@"Style"];

    %init(ReachIt);
}
