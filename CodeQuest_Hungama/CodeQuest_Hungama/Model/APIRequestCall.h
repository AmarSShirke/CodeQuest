//
//  APICall.h
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIRequestCall : NSObject

-(NSMutableURLRequest *)GetAPIURLRequest:(NSString *)URLParamStr;

@end

NS_ASSUME_NONNULL_END
