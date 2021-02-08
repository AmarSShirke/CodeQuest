//
//  MovieDetailsViewController.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.


#import "MovieDetailsViewController.h"
#import "CollectionViewCell.h"

@interface MovieDetailsViewController ()

@end

@implementation MovieDetailsViewController
@synthesize strMovieID,lblCast,lblGenre,lblLanguage,lblOverview,lblReleaseDate,lblMovieTitle,imgBanner,collectionViewCast,collectionViewCrew,collectionViewSimilarMovies,activityIndicatorLoader;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.collectionViewCast.pagingEnabled = YES;
    [self.collectionViewCast registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    self.collectionViewCrew.pagingEnabled = YES;
    [self.collectionViewCrew registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    self.collectionViewSimilarMovies.pagingEnabled = YES;
    [self.collectionViewSimilarMovies registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"CollectionViewCell"];
}

- (void)viewDidAppear:(BOOL)animated{
    
    if ([Network isNetworkAvailable]) {
        activityIndicatorLoader.hidden = NO;
        [activityIndicatorLoader startAnimating];
        [self getMovieDetailsWebserviceCall];
    
    }else{
        [self ShowToast: @"No internet connection"];
    }
    
    if ([Network isNetworkAvailable]) {
        activityIndicatorLoader.hidden = NO;
        [activityIndicatorLoader startAnimating];
        [self getMovieCastWebserviceCall];
    
    }else{
        [self ShowToast: @"No internet connection"];
    }
    
    if ([Network isNetworkAvailable]) {
        activityIndicatorLoader.hidden = NO;
        [activityIndicatorLoader startAnimating];
        [self getSimilarMoviesWebserviceCall];
    
    }else{
        [self ShowToast: @"No internet connection"];
    }

}

#pragma mark -API Calls-

-(void)getMovieDetailsWebserviceCall{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    NSString *strBaseURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"BaseURL"]];
    NSString *SubURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"SubURL"]];
    NSString *APIKey = [NSString stringWithFormat:@"%@",[dict objectForKey:@"APIKey"]];
    NSString *language = [NSString stringWithFormat:@"%@",[dict objectForKey:@"language"]];
    
    NSString *URLParamStr = [NSString stringWithFormat:@"%@%@%@?%@&language=%@",strBaseURL, SubURL, strMovieID, APIKey, language];
    
    NSMutableURLRequest *request = [APIRequestCall GetAPIURLRequest:URLParamStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSString *JsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        self->movieDetailsDict = [JSONParsing convertJSONStringToObject:JsonString];
        
        if(httpResponse.statusCode == 401)
        {
            NSString *strErrorMsg = [self->movieDetailsDict objectForKey:@"status_message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->activityIndicatorLoader stopAnimating];
                self->activityIndicatorLoader.hidden = YES;
                [self ShowToast:strErrorMsg];
             });

        }else{
            if(httpResponse.statusCode == 200){

                
                NSString *strFormatedDate = [self formatedDate: [self->movieDetailsDict objectForKey:@"release_date"]];
                
                //get geners
                NSArray *genersArr = [self->movieDetailsDict objectForKey:@"genres"];
                NSString *strGeners = @"";
                for(int i = 0; i < genersArr.count; i++){
                    
                    strGeners = [strGeners stringByAppendingFormat:@"%@",[[genersArr objectAtIndex:i] objectForKey:@"name"]];
                    strGeners = [strGeners stringByAppendingString:@", "];
                }
                strGeners = [strGeners substringToIndex:[strGeners length]-1];
                
                //get languages
                NSArray *languageArr = [self->movieDetailsDict objectForKey:@"spoken_languages"];
                
                NSString *strSpokenLanguage = @"";
                
                for(int i = 0; i < languageArr.count; i++){
                    
                    strSpokenLanguage = [strSpokenLanguage stringByAppendingFormat:@"%@",[[languageArr objectAtIndex:i] objectForKey:@"name"]];
                    strSpokenLanguage = [strSpokenLanguage stringByAppendingString:@","];
                }
                strSpokenLanguage = [strSpokenLanguage substringToIndex:[strSpokenLanguage length]-1];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // retrive image on global queue
                
                    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
                    NSString *strImageURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ImageURL"]];
                
                    NSString *URLStr = [NSString stringWithFormat:@"%@%@",strImageURL, [self->movieDetailsDict objectForKey:@"backdrop_path"]];

                    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLStr]];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ( [imageData isEqual:[NSNull null]] || [imageData isKindOfClass:[NSNull class]] || imageData.length == 0) {
                            
                            self->imgBanner.image = [UIImage imageNamed:@"poster-placeholder.png"];
                            
                        }else{
                            
                            self->imgBanner.image = [UIImage imageWithData: imageData];
                            
                        }
                    });
                });
                
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                    
                    self->lblMovieTitle.text = [self->movieDetailsDict objectForKey:@"title"];
                    self->lblReleaseDate.text = strFormatedDate;
                    self->lblLanguage.text = strSpokenLanguage;
                    self->lblGenre.text = strGeners;
                    self->lblOverview.text = [self->movieDetailsDict objectForKey:@"overview"];
                  
                 });
                
            }else{
                
                NSString *strErrorMsg = [self->movieDetailsDict objectForKey:@"status_message"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                    [self ShowToast:strErrorMsg];
                 });
            }
        }
    }];
    [dataTask resume];
}

-(void)getMovieCastWebserviceCall{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    NSString *strBaseURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"BaseURL"]];
    NSString *strSubURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"SubURL"]];
    NSString *strCastAPI = [NSString stringWithFormat:@"%@",[dict objectForKey:@"CastAPI"]];
    NSString *APIKey = [NSString stringWithFormat:@"%@",[dict objectForKey:@"APIKey"]];
    NSString *language = [NSString stringWithFormat:@"%@",[dict objectForKey:@"language"]];
    
    NSString *URLParamStr = [NSString stringWithFormat:@"%@%@%@/%@%@&language=%@",strBaseURL, strSubURL, strMovieID, strCastAPI, APIKey, language];
    
    NSMutableURLRequest *request = [APIRequestCall GetAPIURLRequest:URLParamStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSDictionary *movieCastDict;
        NSString *JsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        movieCastDict = [JSONParsing convertJSONStringToObject:JsonString];
        
        if(httpResponse.statusCode == 401)
        {
            NSString *strErrorMsg = [movieCastDict objectForKey:@"status_message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->activityIndicatorLoader stopAnimating];
                self->activityIndicatorLoader.hidden = YES;
                [self ShowToast:strErrorMsg];
             });

        }else{
            
            if(httpResponse.statusCode == 200){

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                 });
        
                self->movieCastArray = [movieCastDict objectForKey:@"cast"];
                self->movieCrewArray = [movieCastDict objectForKey:@"crew"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionViewCast reloadData];
                 });
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionViewCrew reloadData];
                 });
                
        
            }else{
                NSString *strErrorMsg = [movieCastDict objectForKey:@"status_message"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                    [self ShowToast:strErrorMsg];
                 });
            }
        }
    }];
    [dataTask resume];
}

-(void)getSimilarMoviesWebserviceCall{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    NSString *strBaseURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"BaseURL"]];
    NSString *strSubURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"SubURL"]];
    NSString *strSimilarMovieAPI = [NSString stringWithFormat:@"%@",[dict objectForKey:@"SimilarMovieAPI"]];
    NSString *APIKey = [NSString stringWithFormat:@"%@",[dict objectForKey:@"APIKey"]];
    NSString *language = [NSString stringWithFormat:@"%@",[dict objectForKey:@"language"]];
    
    NSString *URLParamStr = [NSString stringWithFormat:@"%@%@%@/%@%@&language=%@",strBaseURL, strSubURL, strMovieID, strSimilarMovieAPI, APIKey, language];
    
    NSMutableURLRequest *request = [APIRequestCall GetAPIURLRequest:URLParamStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSDictionary *similarMoviesDict;
        NSString *JsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        similarMoviesDict = [JSONParsing convertJSONStringToObject:JsonString];
        
        if(httpResponse.statusCode == 401)
        {
            NSString *strErrorMsg = [similarMoviesDict objectForKey:@"status_message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->activityIndicatorLoader stopAnimating];
                self->activityIndicatorLoader.hidden = YES;
                [self ShowToast:strErrorMsg];
             });
            
        }else{
            if(httpResponse.statusCode == 200){
                
                self->similarMoviesArray = [similarMoviesDict objectForKey:@"results"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                    [self.collectionViewSimilarMovies reloadData];
                 });
                
        
            }else{
                NSString *strErrorMsg = [similarMoviesDict objectForKey:@"status_message"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;
                    [self ShowToast:strErrorMsg];
                 });
            }
        }
    }];
    [dataTask resume];
}




#pragma mark -Collection View Methods-

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == collectionViewCast) {
        return movieCastArray.count;
        
    }else if (collectionView == collectionViewCrew){
        return movieCrewArray.count;
    }else{
        return similarMoviesArray.count;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    
    if (collectionView == collectionViewCast) {
        
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // retrive image on global queue
        
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
            NSString *strImageURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ImageURL"]];
        
            NSString *URLStr = [NSString stringWithFormat:@"%@%@",strImageURL, [[self->movieCastArray objectAtIndex:indexPath.item] objectForKey:@"profile_path"]];

            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLStr]];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [imageData isEqual:[NSNull null]] || [imageData isKindOfClass:[NSNull class]] || imageData.length == 0) {
                    
                    cell.imgCast.image = [UIImage imageNamed:@"cast-placeholder.png"];
                    
                }else{
                    
                    cell.imgCast.image = [UIImage imageWithData: imageData];
                    
                }
            });
        });
        
        cell.lblCastName.text = [[movieCastArray objectAtIndex:indexPath.item] objectForKey:@"name"];
        return cell;
        
    }else if (collectionView == collectionViewCrew){
        
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // retrive image on global queue
        
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
            NSString *strImageURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ImageURL"]];
        
            NSString *URLStr = [NSString stringWithFormat:@"%@%@",strImageURL, [[self->movieCrewArray objectAtIndex:indexPath.item] objectForKey:@"profile_path"]];
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLStr]];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [imageData isEqual:[NSNull null]] || [imageData isKindOfClass:[NSNull class]] || imageData.length == 0) {
                    
                    cell.imgCast.image = [UIImage imageNamed:@"cast-placeholder.png"];
                    
                }else{
                    
                    cell.imgCast.image = [UIImage imageWithData: imageData];
                }
            });
        });
        
        cell.lblCastName.text = [[movieCastArray objectAtIndex:indexPath.item] objectForKey:@"name"];
        return cell;
        
    }else{
        
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // retrive image on global queue
            
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
            NSString *strImageURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ImageURL"]];
        
            NSString *URLStr = [NSString stringWithFormat:@"%@%@",strImageURL, [[self->similarMoviesArray objectAtIndex:indexPath.item] objectForKey:@"poster_path"]];
        
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLStr]];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [imageData isEqual:[NSNull null]] || [imageData isKindOfClass:[NSNull class]] || imageData.length == 0) {
                    
                    cell.imgCast.image = [UIImage imageNamed:@"poster-placeholder.png"];
                    
                }else{
                    
                    cell.imgCast.image = [UIImage imageWithData: imageData];
                }
            });
        });
        
        cell.lblCastName.text = [[similarMoviesArray objectAtIndex:indexPath.item] objectForKey:@"title"];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 160);
}

#pragma mark -button click Methods-

-(IBAction)backToListBtnPress:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark -Show Toast Method-

- (void) ShowToast:(NSString *)Message {
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIView *firstSubview = alert.view.subviews.firstObject;
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0f];
    }
    NSMutableAttributedString *AS = [[NSMutableAttributedString alloc] initWithString:Message];
    [AS addAttribute: NSForegroundColorAttributeName value: [UIColor whiteColor] range: NSMakeRange(0,AS.length)];
    [alert setValue:AS forKey:@"attributedTitle"];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
    });
}

#pragma mark -Format Date Method-
-(NSString *)formatedDate:(NSString *) dateString{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:dateString];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //Get Date
    [formatter setDateFormat:@"dd"];
    NSString *strDate = [formatter stringFromDate:date];

    //Get Month
    [formatter setDateFormat:@"MMM"];
    NSString *strMonth = [formatter stringFromDate:date];

    //Get Year
    [formatter setDateFormat:@"yyyy"];
    NSString *strYear = [formatter stringFromDate:date];
    
    NSString *strFormatedDate = [NSString stringWithFormat:@"%@ %@, %@", strMonth, strDate, strYear];
    return strFormatedDate;
}
@end
