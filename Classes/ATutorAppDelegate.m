//
//  ATutorAppDelegate.m
//  ATutor
//
//  Created by Quang Anh Do on 25/05/2010.
//  Copyright Quang Anh Do 2010. All rights reserved.
//

#import "ATutorAppDelegate.h"
#import "StyleSheet.h"
#import "OSConsumer.h"

#import "ActivitiesViewController.h"
#import "ContactsViewController.h"

@interface ATutorAppDelegate (Private) 

- (void)wireUpNavigator;

@end


@implementation ATutorAppDelegate

@synthesize window;
@synthesize consumer;
@synthesize launcher;
@synthesize webController;
@synthesize helper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	// Set service consumer
	consumer = [[OSConsumer alloc] init];
	
	// Set global stylesheet
	[TTDefaultStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];	
	
	// Set web controller handler
	launcher = [[LauncherViewController alloc] initWithConsumer:consumer];
	
	webController = [[QAWebController alloc] init];
	webController.oAuthDelegate = launcher;
	
	// Update friend list
	helper = [[ATutorHelper alloc] initWithConsumer:consumer];
	[helper setDelegate:self];
	[helper fetchFriendList];
	
	return YES;
}


- (void)dealloc {
    [window release];
	[consumer release];
	[launcher release];
	[webController release];
	[helper release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Misc

- (void)wireUpNavigator {
	TTNavigator *navigator = [TTNavigator navigator];
	navigator.window = window;
	navigator.persistenceMode = TTNavigatorPersistenceModeNone;
	
	TTURLMap *map = navigator.URLMap;
	[map from:@"*" toViewController:webController];
	[map from:@"atutor://launcher" toViewController:launcher];
	[map from:@"atutor://activities" toViewController:[ActivitiesViewController class]];
	[map from:@"atutor://contacts" toViewController:[ContactsViewController class]];
	
	// Display launcher 
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"atutor://launcher"]];
}

- (void)doneFetchingFriendList {
	[self wireUpNavigator];
}

@end
