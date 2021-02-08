//
//  JSONParsing.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 08/02/21.
//

#import "JSONParsing.h"

@implementation JSONParsing

-(NSDictionary *) convertJSONStringToObject:(NSString *)datastring{
    
    if(NSClassFromString(@"NSJSONSerialization")){
        
        NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[datastring dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if(error) {
            NSLog(@"%@",error.localizedDescription);
        }
        
        if([object isKindOfClass:[NSArray class]]){
            return (NSDictionary *)object;
        }
        if([object isKindOfClass:[NSDictionary class]]){
            return (NSDictionary *)object;
        }
    }
    return nil;
}

@end
