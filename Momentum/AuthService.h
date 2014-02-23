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

#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#pragma mark * Block Definitions


typedef void (^CompletionBlock) ();
typedef void (^CompletionWithStringBlock) (NSString *string);
typedef void (^CompletionWithIndexBlock) (NSUInteger index);


@interface AuthService : NSObject <MSFilter>
@property (nonatomic, strong)   NSString *authProvider;
@property (nonatomic, strong)   MSClient *client;

/**
 *  Creates a new static instance(will stay in memory) of authService,
 * a singleton implementation. If an instance is already in memory it
 * will return that instance. Implemented as a singleton for ease of use
 * across multiple classes
 *
 *  @return reference to current authService
 */
+(AuthService*) getInstance;

/**
 * Handles registering a custom auth account
 */
- (void) registerAccount:(NSDictionary *) item
              completion:(MSAPIBlock) completion;

/**
 * Logins in a user using their custom auth account
 */
- (void) loginAccount:(NSDictionary *) item
           completion:(MSAPIBlock) completion;


/**
 * Calls a server side method that will by deftault return a 401
 * The retry parameter indicates if we should retry it after making the user
 * relogin.
 */
- (void) testForced401:(BOOL)shouldRetry withCompletion:(CompletionWithStringBlock) completion;

/**
 * Method that will save authentication info from azure. The method will
 * be encrypted into the keychain using an auxillary keychain wrapper
 * class. The data encrypted is the data that has been stored inside
 * the MSClient; the authentication token and the user id.
 * When the information needs to be loaded again, loadAuthdata is
 * called which will load the data into the MSClient
 */
- (void)saveAuthInfo;

/**
 * Method that will load the authentication info into the MSClient.
 * This is called in the init method of the class
 */
- (void)loadAuthInfo;

/**
 *  Removes all the authentication info from the keychain. This 
 * method is used when an error has occurred during authentication
 * or if the user wants to log out.
 */
- (void)killAuthInfo;

- (void) handleRequest:(NSURLRequest *)request
                  next:(MSFilterNextBlock)onNext
              response:(MSFilterResponseBlock)onResponse;


@end
