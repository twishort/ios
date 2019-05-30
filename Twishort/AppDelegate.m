
#import "AppDelegate.h"
#import "ViewController.h"
#import <TwitterKit/TWTRKit.h>
#import "TmhSocialTwitter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)customizeInterface {
    [UINavigationBar appearance].barTintColor = TmhColor(@"ColorTint");
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
    [self customizeInterface];
    if (IOS11) {
        [[Twitter sharedInstance] startWithConsumerKey:kTmhSocialTwitterConsumerKey consumerSecret:kTmhSocialTwitterConsumerSecret];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if (IOS11 
        && [[Twitter sharedInstance] application:application openURL:url options:@{}]) {
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    ViewController *vc = (ViewController *)((UINavigationController *)self.window.rootViewController).viewControllers[0];
    if ([vc respondsToSelector:@selector(saveShare)]) {
        [vc saveShare];
    }
}


@end
