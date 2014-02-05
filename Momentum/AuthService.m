/*
 Copyright 2013 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "AuthService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "KeychainWrapper.h"
#import "FBCDAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#pragma mark * Private interace


@interface AuthService()

//this is the authentication table to connect to
@property (nonatomic, strong)   MSTable *authTable;
//this is the users table to connect to
@property (nonatomic, strong)   MSTable *usersTable;
@property (nonatomic)           BOOL shouldRetryAuth;
@property (nonatomic, strong)   NSString *keychainName;
@property (nonatomic, strong)   NSMutableData *receivedData;

@end


@implementation AuthService

static AuthService *singletonInstance;

+ (AuthService*)getInstance{
    if (singletonInstance == nil) {
        singletonInstance = [[super alloc] init];
    }
    return singletonInstance;
}

-(AuthService *) init
{
    self = [super init];
    if (self) {
        // Initialize the Mobile Service client with your URL and key
        self.client = [(FBCDAppDelegate *) [[UIApplication sharedApplication] delegate] client];
        
        self.client = [self.client clientWithFilter:self];
        
        self.keychainName = @"keychain";
        [self loadAuthInfo];
        
        self.authTable = [_client tableWithName:@"AuthData"];
        self.usersTable = [_client tableWithName:@"Users"];
    }
    
    return self;
}

- (void) getAuthDataOnSuccess:(CompletionWithStringBlock) completion {
    [self.authTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        [self logErrorIfNotNil:error];
        NSString *user = [NSString stringWithFormat:@"username: %@", [[items objectAtIndex:0] objectForKey:@"UserName"]];
        completion(user);
    }];
}


//register an account using azure and get authentication
//token back using the custom register
- (void) registerAccount:(NSDictionary *) item
              completion:(CompletionWithStringBlock) completion {
    [self.usersTable insert:item completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
        if (error) {
            completion([error localizedDescription]);
            return;
        } else {
            MSUser *user = [[MSUser alloc] initWithUserId:[item valueForKey:@"userId"]];
            user.mobileServiceAuthenticationToken = [item valueForKey:@"token"];
            self.client.currentUser = user;
            [self saveAuthInfo];
            completion(@"SUCCESS");
        }
    }];
}

#pragma mark login logic
//this is for the custom login
- (void) loginAccount:(NSDictionary *) item
           completion:(CompletionWithStringBlock) completion {
    NSDictionary *params = @{ @"login" : @"true"};
    [self.usersTable insert:item parameters:params completion:^(NSDictionary *item, NSError *error) {
        
        [self logErrorIfNotNil:error];
        if (error) {
            completion([error localizedDescription]);
            return;
        } else {
            MSUser *user = [[MSUser alloc] initWithUserId:[item valueForKey:@"userId"]];
            user.mobileServiceAuthenticationToken = [item valueForKey:@"token"];
            self.client.currentUser = user;
            [self saveAuthInfo];
            completion(@"SUCCESS");
        }
    }];
}

- (void) testForced401:(BOOL)shouldRetry withCompletion:(CompletionWithStringBlock) completion {
    
    MSTable *badAuthTable = [_client tableWithName:@"BadAuth"];
    NSDictionary *item = @{ @"data" : @"data"};
    self.shouldRetryAuth = shouldRetry;
    [badAuthTable insert:item completion:^(NSDictionary *item, NSError *error) {
        [self logErrorIfNotNil:error];
        completion(@"Retried auth success");
    }];
}

- (void) logErrorIfNotNil:(NSError *) error {
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}


- (void) handleRequest:(NSURLRequest *)request
                  next:(MSFilterNextBlock)onNext
              response:(MSFilterResponseBlock)onResponse {
    onNext(request, ^(NSHTTPURLResponse *response, NSData *data, NSError *error){
        [self filterResponse:response
                     forData:data
                   withError:error
                  forRequest:request
                      onNext:onNext
                  onResponse:onResponse];
    });
}

- (void) filterResponse: (NSHTTPURLResponse *) response
                forData: (NSData *) data
              withError: (NSError *) error
             forRequest:(NSURLRequest *) request
                 onNext:(MSFilterNextBlock) onNext
             onResponse: (MSFilterResponseBlock) onResponse
{
    if (response.statusCode == 401) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"401" object:nil];
        
        [self killAuthInfo];
        NSLog(@"%ld",(long)response.statusCode);
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        //we're forcing custom auth to relogin from the root for now
        if (self.shouldRetryAuth && ![self.authProvider isEqualToString:@"Custom"]) {
            // show the login dialog
            [self.client loginWithProvider:self.authProvider controller:[[[[UIApplication sharedApplication] delegate] window] rootViewController] animated:YES completion:^(MSUser *user, NSError *error) {
                if (error && error.code == -9001) {
                    // user cancelled authentication
                    //Log them out here too
                    [self triggerLogout];
                    return;
                }
                [self saveAuthInfo];
                NSMutableURLRequest *newRequest = [request mutableCopy];
                //Update the zumo auth token header in the request
                [newRequest setValue:self.client.currentUser.mobileServiceAuthenticationToken forHTTPHeaderField:@"X-ZUMO-AUTH"];
                //Add our bypass query string parameter so this request doesn't get a 401
                newRequest = [self addQueryStringParamToRequest:newRequest];
                onNext(newRequest, ^(NSHTTPURLResponse *innerResponse, NSData *innerData, NSError *innerError){
                    [self filterResponse:innerResponse
                                 forData:innerData
                               withError:innerError
                              forRequest:request
                                  onNext:onNext
                              onResponse:onResponse];
                });
            }];
        } else {
            [self triggerLogout];
        }
    }
    else {
        onResponse(response, data, error);
    }
}

//What's interesting here is that even if we're currently in a modal (Deep Modal) this will fetch the top most VC from the NAV (in this demo that would be the loggedInVC) and execute it's logoutSegue.  This still works even though the modal is showing
-(void)triggerLogout {
    [self killAuthInfo];
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UINavigationController *navVC = (UINavigationController *)rootVC;
    UIViewController *topVC = navVC.topViewController;
}

-(NSMutableURLRequest *)addQueryStringParamToRequest:(NSMutableURLRequest *)request {
    NSMutableString *absoluteURLString = [[[request URL] absoluteString] mutableCopy];
    NSString *newQuery = @"?bypass=true";
    [absoluteURLString appendString:newQuery];
    [request setURL:[NSURL URLWithString:absoluteURLString]];
    return request;
}

#pragma mark saving auth
//save the authentication token to the phone and also chuck it into the
//keychain for security
- (void)saveAuthInfo {
    [KeychainWrapper createKeychainValue:self.client.currentUser.userId forIdentifier:@"userid"];
    [KeychainWrapper createKeychainValue:self.client.currentUser.mobileServiceAuthenticationToken forIdentifier:@"token"];
}

//load the auth information from the keychain
- (void)loadAuthInfo {
    NSString *userid = [KeychainWrapper keychainStringFromMatchingIdentifier:@"userid"];
    if (userid) {
        NSLog(@"userid: %@", userid);
        self.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.client.currentUser.mobileServiceAuthenticationToken = [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"];
    }
}

//this is when you want to remove the authentication token from
//the system, and login with another account
- (void)killAuthInfo {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"userid"];
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"token"];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
    for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
    }
    [self.client logout];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"Log");
}



@end