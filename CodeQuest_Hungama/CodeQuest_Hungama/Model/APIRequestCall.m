//
//  APICall.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.
//

#import "APIRequestCall.h"
#import <UIKit/UIKit.h>

@implementation APIRequestCall


-(NSMutableURLRequest *)GetAPIURLRequest:(NSString *)URLParamStr{
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLParamStr]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
    
}


@end
