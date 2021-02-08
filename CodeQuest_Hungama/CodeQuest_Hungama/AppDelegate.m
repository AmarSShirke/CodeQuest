//
//  AppDelegate.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.
//

#import "AppDelegate.h"
#import "MoviesListViewController.h"
#import "MovieDetailsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize navigation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MoviesListViewController *view = [[MoviesListViewController alloc]initWithNibName:@"MoviesListViewController" bundle:[NSBundle mainBundle]];
    navigation = [[UINavigationController alloc] initWithRootViewController:view];
    
    [self.window makeKeyWindow];
    self.window.rootViewController = self.navigation;
    [self.window makeKeyAndVisible];
    
    self.navigation.navigationBar.hidden = YES;

    return YES;
}





@end
