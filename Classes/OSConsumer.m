//
//  OSConsumer.m
//  ATutor
//
//  Created by Quang Anh Do on 29/05/2010.
//  Copyright 2010 Quang Anh Do. All rights reserved.
//

#import "OSConsumer.h"
#import "OSProvider.h"
#import "SFHFKeychainUtils.h"
#import "OAMutableURLRequest.h"
#import "OAServiceTicket.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAToken.h"
#import "OAToken_KeychainExtensions.h"

@interface OSConsumer (Private)
- (void)setupConsumer;
- (void)getRequestToken;
- (void)requestTokenCallback:(OAServiceTicket *)ticket didFinishWithResponse:(id)response;
- (void)getAccessToken;
- (void)accessTokenCallback:(OAServiceTicket *)ticket didFinishWithResponse:(id)response;
@end

@implementation OSConsumer

@synthesize callbackScheme, consumer, accessToken, currentProvider;

- (void)dealloc {
	[callbackScheme release];
	[consumer release];
	[accessToken release];
	[currentProvider release];
	
	[super dealloc];
}

- (id)init {
	if (self = [super init]) {
		self.callbackScheme = kATutor;
		self.accessToken = [[[OAToken alloc] initWithKeychainUsingAppName:kATutor tokenType:@"accessToken"] autorelease];
		self.currentProvider = [OSProvider getATutorProviderWithKey:kConsumerKey withSecret:kConsumerSecret];
		
		[self setupConsumer];
	}
	
	return self;
}

- (void)startAuthProcess {
	[self getRequestToken];
}

- (void)finishAuthProcess {
	[self getAccessToken];
}

// Should be called within a handleOpenUrl method. 
// This method assumes the request token was authorized and will retrieve the access token
- (void)clearAuthentication {
	[SFHFKeychainUtils storeUsername:@"accessToken" andPassword:@"" forServiceName:kATutor updateExisting:TRUE error:nil];
	[SFHFKeychainUtils storeUsername:@"requestToken" andPassword:@"" forServiceName:kATutor updateExisting:TRUE error:nil];
	
	self.accessToken = nil;
}

- (void)getDataForUrl:(NSString *)relativeUrl andParameters:(NSArray*)params 
             delegate:(id)delegate didFinishSelector:(SEL)didFinishSelector {
	if (!accessToken) {
		[self startAuthProcess];  
		return;
	}
	
	NSLog(@"Getting data with access token: %@ : %@", [accessToken key], [accessToken secret]);
	
	NSString *url = [[currentProvider endpointUrl] stringByAppendingString:relativeUrl];  
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] 
									 initWithURL:[NSURL URLWithString:url]
									 consumer:consumer token:accessToken] autorelease]; 
	[request setHTTPMethod:@"GET"];
	
	[OADataFetcher fetchDataWithRequest:request delegate:delegate
					  didFinishSelector:didFinishSelector];
}

#pragma mark -
#pragma mark Private

- (void)setupConsumer {
	self.consumer = [[[OAConsumer alloc] initWithKey:[currentProvider consumerKey] 
											  secret:[currentProvider consumerSecret]] autorelease];
}

- (void)getRequestToken {
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] 
									 initWithURL:[NSURL URLWithString:[currentProvider requestUrl]] 
									 parameters:[currentProvider extraRequestUrlParams]
									 consumer:consumer 
									 token:nil] autorelease];
	[request setHTTPMethod:@"GET"];
	
	[OADataFetcher fetchDataWithRequest:request
							   delegate:self
					  didFinishSelector:@selector(requestTokenCallback:didFinishWithResponse:)];
}

- (void)requestTokenCallback:(OAServiceTicket *)ticket didFinishWithResponse:(id)response {
	if (ticket.didSucceed) {
		NSLog(@"%@", response);
		OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:response];
		[requestToken storeInDefaultKeychainWithAppName:@"opensocial-demo" tokenType:@"requestToken"];    
		NSLog(@"Stored this secret and key: %@ : %@", [requestToken key], [requestToken secret]);
		
		NSString *urlString = [NSString stringWithFormat:@"%@?oauth_callback=%@://&oauth_token=%@", 
							   [currentProvider authorizeUrl], callbackScheme, [requestToken key]];
		
		NSLog(@"Request string: %@", urlString);
		
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];
	} else {
		NSString *error = [NSString stringWithFormat:@"Got error while requesting request token. %@", response];
		NSLog(@"Error retriving request token: %@", error);
		
		@throw [NSException exceptionWithName:@"RequestTokenException" reason:error  userInfo:nil];
	}
}

- (void)getAccessToken {  
	OAToken *requestToken = [[OAToken alloc] initWithKeychainUsingAppName:kATutor 
																tokenType:@"requestToken"];
	NSLog(@"Getting access token for request token: %@ : %@", [requestToken key], [requestToken secret]);
	
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] 
									 initWithURL:[NSURL URLWithString:[currentProvider accessUrl]]
									 consumer:consumer token:requestToken] autorelease];
	[request setHTTPMethod:@"GET"];
	
	[OADataFetcher fetchDataWithRequest:request delegate:self
					  didFinishSelector:@selector(accessTokenCallback:didFinishWithResponse:)];
}

- (void)accessTokenCallback:(OAServiceTicket *)ticket didFinishWithResponse:(id)response {
	if (ticket.didSucceed) {
		self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:response] autorelease];
		[accessToken storeInDefaultKeychainWithAppName:kATutor tokenType:@"accessToken"];
		
		NSLog(@"Got an access token: %@ : %@", [accessToken key], [accessToken secret]);
		
	} else {
		NSString *error = [NSString stringWithFormat:@"Got error while requesting access token. %@", response];
		NSLog(@"Error retriving access token: %@", error);
		
		@throw [NSException exceptionWithName:@"AccessTokenException" reason:error  userInfo:nil];
	}
}

@end