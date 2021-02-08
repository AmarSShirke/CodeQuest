//
//  JSONParsing.h
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 08/02/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONParsing : NSObject

-(NSDictionary *) convertJSONStringToObject:(NSString *)datastring;

@end

NS_ASSUME_NONNULL_END
