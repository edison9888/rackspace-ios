//
//  GetServersRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetServersRequest.h"
#import "OpenStackAccount.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "AccountManager.h"
#import "OSComputeEndpoint.h"


@implementation GetServersRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetServersRequest *request = [[[GetServersRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];    
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
    request.validatesSecureCertificate = !account.ignoresSSLValidation;
	return request;
}

+ (id)serversRequest:(OpenStackAccount *)account endpoint:(OSComputeEndpoint *)endpoint method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = nil;;
    if (endpoint && endpoint.publicURL) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?now=%@", endpoint.publicURL, path, now]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?now=%@", account.serversURL, path, now]];
    }
    return [GetServersRequest request:account method:method url:url];
}

+ (id)serversRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    return [self serversRequest:account endpoint:nil method:method path:path];
}


+ (GetServersRequest *)request:(OpenStackAccount *)account {
    GetServersRequest *request = [GetServersRequest serversRequest:account method:@"GET" path:@"/servers/detail"];
    request.account = account;
    return request;
}

+ (GetServersRequest *)request:(OpenStackAccount *)account endpoint:(OSComputeEndpoint *)endpoint {
    GetServersRequest *request = [GetServersRequest serversRequest:account endpoint:endpoint method:@"GET" path:@"/servers/detail"];
    request.account = account;
    return request;
}

- (void)requestFinished {        
    if ([self isSuccess]) {
        
        account.servers = [NSMutableDictionary dictionaryWithDictionary:[self servers]];
        
        NSArray *keys = [account.servers allKeys];
        NSMutableDictionary *fullServers = [[NSMutableDictionary alloc] initWithCapacity:[keys count]];
        for (int i = 0; i < [keys count]; i++) {
            Server *server = [self.account.servers objectForKey:[keys objectAtIndex:i]];            
            server.image = [self.account.images objectForKey:server.imageId];
            server.flavor = [self.account.flavors objectForKey:server.flavorId];
            [fullServers setObject:server forKey:server.identifier];            
        }
        self.account.servers = [NSMutableDictionary dictionaryWithDictionary:fullServers];
        [fullServers release];
        [self.account persist];
    }
    [super requestFinished];
}

@end
