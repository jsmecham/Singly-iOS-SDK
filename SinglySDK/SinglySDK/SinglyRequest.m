//
//  SinglyRequest.m
//  SinglySDK
//
//  Copyright (c) 2012-2013 Singly, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+URLEncoding.h"

#import "SinglyConstants.h"
#import "SinglyRequest.h"
#import "SinglyRequest+Internal.h"
#import "SinglySession.h"

@implementation SinglyRequest

@synthesize endpoint = _endpoint;
@synthesize isAuthorizedRequest = _isAuthorizedRequest;
@synthesize parameters = _parameters;

+ (id)requestWithEndpoint:(NSString *)endpoint
{
    SinglyRequest *request = [[SinglyRequest alloc] initWithEndpoint:endpoint];
    return request;
}

+ (id)requestWithEndpoint:(NSString *)endpoint andParameters:(NSDictionary *)parameters
{
    SinglyRequest *request = [[SinglyRequest alloc] initWithEndpoint:endpoint andParameters:parameters];
    return request;
}

- (id)initWithEndpoint:(NSString *)endpoint
{
    self = [self initWithEndpoint:endpoint andParameters:nil];
    return self;
}

- (id)initWithEndpoint:(NSString *)endpoint andParameters:(NSDictionary *)parameters
{
    self = [super init];
    if (self)
    {

        // Default Values
        self.endpoint = endpoint;
        self.parameters = parameters;
        self.isAuthorizedRequest = YES;

        // Add Custom Headers
        [self setCustomHeaders];

        // Update Request URL
        [self updateURL];

    }
    return self;
}

#pragma mark - Properties

- (void)setEndpoint:(NSString *)endpoint
{
    @synchronized(self)
    {
        _endpoint = [endpoint copy];
        [self updateURL];
    }
}

- (NSString *)endpoint
{
    @synchronized(self)
    {
        return _endpoint;
    }
}

- (void)setIsAuthorizedRequest:(BOOL)isAuthorizedRequest
{
    @synchronized(self)
    {
        _isAuthorizedRequest = isAuthorizedRequest;
        [self updateURL];
    }
}

- (BOOL)isAuthorizedRequest
{
    @synchronized(self)
    {
        return _isAuthorizedRequest;
    }
}

- (void)setParameters:(NSDictionary *)parameters
{
    @synchronized(self)
    {
        _parameters = [parameters copy];
        [self updateURL];
    }
}

- (NSDictionary *)parameters
{
    @synchronized(self)
    {
        return _parameters;
    }
}

#pragma mark - Endpoint URLs

- (void)updateURL
{
    self.URL = [SinglyRequest URLForEndpoint:self.endpoint
                              withParameters:self.parameters
                            andAuthorization:self.isAuthorizedRequest];
}

+ (NSURL *)URLForEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters
{
    return [SinglyRequest URLForEndpoint:endpoint
                          withParameters:parameters
                        andAuthorization:YES];
}

+ (NSURL *)URLForEndpoint:(NSString *)endpoint
           withParameters:(NSDictionary *)parameters
         andAuthorization:(BOOL)isAuthorized
{
    NSMutableString *apiURLString = [NSMutableString stringWithFormat:@"%@/%@", SinglySession.sharedSession.baseURL, endpoint];
    NSMutableArray *parameterComponents = [NSMutableArray array];

    // Add Parameters to URL
    if (parameters && parameters.count > 0)
    {
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            if (![value isKindOfClass:[NSNull class]])
                [parameterComponents addObject:[NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [value URLEncodedString]]];
        }];
    }

    // Add Singly Access Token to URL
    if (isAuthorized && SinglySession.sharedSession.accessToken)
        [parameterComponents addObject:[NSString stringWithFormat:@"access_token=%@", SinglySession.sharedSession.accessToken]];

    if (parameterComponents.count > 0)
    {
        [apiURLString appendString:@"?"];
        [apiURLString appendString:[parameterComponents componentsJoinedByString:@"&"]];
    }

    return [NSURL URLWithString:apiURLString];
}

#pragma mark - Custom Headers

- (void)setAllHTTPHeaderFields:(NSDictionary *)headerFields
{
    [self setCustomHeaders];
    [super setAllHTTPHeaderFields:headerFields];
}

- (void)setCustomHeaders
{
    [self setValue:@"iOS" forHTTPHeaderField:@"X-Singly-SDK"];
    [self setValue:kSinglySDKVersion forHTTPHeaderField:@"X-Singly-SDK-Version"];
}

@end
