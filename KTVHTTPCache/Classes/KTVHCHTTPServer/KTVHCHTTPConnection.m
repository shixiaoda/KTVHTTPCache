//
//  KTVHCHTTPConnection.m
//  KTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "KTVHCHTTPConnection.h"
#import "KTVHCHTTPRequest.h"
#import "KTVHCHTTPResponse.h"
#import "KTVHCHTTPResponsePing.h"
#import "KTVHCHTTPURL.h"
#import "KTVHCDataRequest.h"
#import "KTVHCLog.h"

#import "KTVHCM3u8Unit.h"
#import "KTVHCHTTPServer.h"
#import "KTVHCDataUnitPool.h"

@implementation KTVHCHTTPConnection


+ (NSString *)responsePingTokenString
{
    return KTVHCHTTPResponsePingTokenString;
}

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig
{
    if (self = [super initWithAsyncSocket:newSocket configuration:aConfig])
    {
        KTVHCLogAlloc(self);
    }
    return self;
}

- (void)dealloc
{
    KTVHCLogDealloc(self);
}


- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    KTVHCLogHTTPConnection(@"receive request, %@, %@", method, path);
    
    KTVHCHTTPURL * URL = [KTVHCHTTPURL URLWithServerURIString:path];
    
    switch (URL.type)
    {
        case KTVHCHTTPURLTypeM3u8:
        {
//            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"index.m3u8"];
            
            KTVHCM3u8Unit * m3u8Unit = [[KTVHCDataUnitPool unitPool].m3u8UnitQueue unitWithUniqueIdentifier:URL.originalURLString];
            if (m3u8Unit == nil) {
                m3u8Unit = [[KTVHCM3u8Unit alloc] initWithContentOfURL:URL.originalURLString error:nil];
//                [m3u8Unit generateProxyM3u8ToPath:nil proxyURLStringBlock:^NSString *(NSString * originalUrlstring) {
//                    NSString *proxyURLString = originalUrlstring;
//                    if (![proxyURLString hasPrefix:@"http"]) {
//                        proxyURLString = [[m3u8Unit.URLString stringByDeletingLastPathComponent] stringByAppendingPathComponent:proxyURLString];
//                    }
//
//                    KTVHCHTTPURL * url = [KTVHCHTTPURL URLWithOriginalURLString:proxyURLString];
//                    proxyURLString = [url proxyURLStringWithServerPort:[KTVHCHTTPServer server].coreHTTPServer.listeningPort];
//
//                    return proxyURLString;
//
//                } error:nil];
                
                [[KTVHCDataUnitPool unitPool].m3u8UnitQueue putUnit:m3u8Unit];
                
                [[KTVHCDataUnitPool unitPool].m3u8UnitQueue archive];
            }
            
            NSData *data = [m3u8Unit.originalText dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:data];
//            return [[HTTPAsyncFileResponse alloc] initWithFilePath:path forConnection:self];
        }
        case KTVHCHTTPURLTypePing:
        {
            KTVHCHTTPResponsePing * currentResponse = [KTVHCHTTPResponsePing responseWithConnection:self];
            
            return currentResponse;
        }
        case KTVHCHTTPURLTypeContent:
        {
            KTVHCHTTPRequest * currentRequest = [KTVHCHTTPRequest requestWithOriginalURLString:URL.originalURLString];
            
            currentRequest.isHeaderComplete = request.isHeaderComplete;
            currentRequest.allHTTPHeaderFields = request.allHeaderFields;
            currentRequest.URL = request.url;
            currentRequest.method = request.method;
            currentRequest.statusCode = request.statusCode;
            currentRequest.version = request.version;
            
            KTVHCDataRequest * dataRequest = [currentRequest dataRequest];
            KTVHCHTTPResponse * currentResponse = [KTVHCHTTPResponse responseWithConnection:self dataRequest:dataRequest];
            
            return currentResponse;
        }
    }
    return nil;
}


@end
