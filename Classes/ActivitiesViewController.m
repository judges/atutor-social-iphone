//
//  ActivitiesViewController.m
//  ATutor
//
//  Created by Quang Anh Do on 07/06/2010.
//  Copyright 2010 Quang Anh Do. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "CommonFunctions.h"
#import "OSConsumer.h"
#import "OAServiceTicket.h"
#import "NSDictionary_JSONExtensions.h"
#import "ATutorAppDelegate.h"


@implementation ActivitiesViewController

- (id)init {
	if (self = [super init]) {
		self.title = @"Activities";
		self.autoresizesForKeyboard = YES;
		self.variableHeightRows = YES;
		
		OSConsumer *consumer = [(ATutorAppDelegate *)[[UIApplication sharedApplication] delegate] consumer];
		[consumer getDataForUrl:@"/activities/@me/@self" 
				  andParameters:nil 
					   delegate:self 
			  didFinishSelector:@selector(activitiesCallback:didFinishWithResponse:)];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];

	self.tableView.allowsSelection = NO;
}

- (void)activitiesCallback:(OAServiceTicket *)ticket didFinishWithResponse:(id)response {
	if (ticket.didSucceed) {
		NSError *error = nil;
		NSDictionary *data = [NSDictionary dictionaryWithJSONData:[response dataUsingEncoding:NSUTF8StringEncoding] error:&error];
		
		int numberOfItems = [[data objectForKey:@"totalResults"] intValue] % [[data objectForKey:@"itemsPerPage"] intValue];
		
		TTListDataSource *dataSource = [[[TTListDataSource alloc] init] autorelease];
		for (int i = 0; i < numberOfItems; i++) {
			NSString *entry = [[[data objectForKey:@"entry"] objectAtIndex:i] objectForKey:@"title"];
			TTStyledText *text = [TTStyledText textFromXHTML:entry];
			[dataSource.items addObject:[TTTableStyledTextItem itemWithText:text URL:nil]];
		}
		
		self.dataSource = dataSource;
	} else {
		alertMessage(@"Error", @"Unable to process your request");
	}
}

@end