//
//  Network.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 08/02/21.
//

#import "Network.h"

@implementation Network

-(BOOL)isNetworkAvailable{
    char *hostname;
    struct hostent *hostinfo;
    
    hostname = "www.google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }else{
        NSLog(@"-> connection established!\n");
        
        return YES;
    }
}

@end
