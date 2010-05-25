    //
//  LauncherViewController.m
//  ATutor
//
//  Created by Quang Anh Do on 25/05/2010.
//  Copyright 2010 Quang Anh Do. All rights reserved.
//

#import "LauncherViewController.h"


@implementation LauncherViewController

- (id)init {
	if (self = [super init]) {
		self.title = @"ATutor Social";
	}
	
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadView {
	[super loadView];
	
	launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
	launcherView.delegate = self;
	launcherView.backgroundColor = [UIColor colorWithRed:0.875 green:0.871 blue:0.925 alpha:1.000];
	launcherView.columnCount = 2;
	
	for (NSString *module in [NSArray arrayWithObjects:@"Activities", @"Contacts", @"Gadgets", @"Groups", nil]) {
		[launcherView addItem:[[[TTLauncherItem alloc] initWithTitle:module 
															   image:nil
																 URL:[NSString stringWithFormat:@"atutor://modules/%@", module] 
														   canDelete:NO] autorelease] 
					 animated:NO];
	}
	
	[self.view addSubview:launcherView];
}


- (void)dealloc {
	[launcherView release];
	
    [super dealloc];
}


@end
