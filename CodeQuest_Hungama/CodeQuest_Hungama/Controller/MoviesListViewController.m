//
//  MoviesListViewController.m
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.

#import "MoviesListViewController.h"
#import "MovieDetailsViewController.h"
#import "MovieInfoTableViewCell.h"

@interface MoviesListViewController ()

@end

@implementation MoviesListViewController
@synthesize tblMoviesList,recentlySearchedView,tblRecentlySearchedList,movieSearchBar,activityIndicatorLoader;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tblMoviesList.separatorColor = [UIColor clearColor];
    duplicatemovieListArray = [[NSMutableArray alloc] init];
    movieListArray = [[NSMutableArray alloc] init];
    filterArray = [[NSMutableArray alloc] init];
    recentlySearchArray = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    
    activityIndicatorLoader.hidden = YES;
    
    [movieSearchBar resignFirstResponder];
    recentlySearchedView.hidden = YES;
    isSearchedMovie = NO;
    
    if ([Network isNetworkAvailable]) {
        activityIndicatorLoader.hidden = NO;
        [activityIndicatorLoader startAnimating];
        [self getMoviesListWebserviceCall];
    
    }else{
        [self ShowToast: @"No internet connection"];
    }
    
}

#pragma mark -API Call-

-(void)getMoviesListWebserviceCall{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    NSString *strBaseURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"BaseURL"]];
    NSString *SubURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"SubURL"]];
    NSString *movieListAPI = [NSString stringWithFormat:@"%@",[dict objectForKey:@"movieListAPI"]];
    NSString *APIKey = [NSString stringWithFormat:@"%@",[dict objectForKey:@"APIKey"]];
    NSString *language = [NSString stringWithFormat:@"%@",[dict objectForKey:@"language"]];
    
    NSString *URLParamStr = [NSString stringWithFormat:@"%@%@%@%@&language=%@",strBaseURL, SubURL, movieListAPI, APIKey, language];
    
    NSMutableURLRequest *request = [APIRequestCall GetAPIURLRequest:URLParamStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSString *JsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSDictionary *dictionary = [JSONParsing convertJSONStringToObject:JsonString];
        
        if(httpResponse.statusCode == 401)
        {
            NSString *strErrorMsg = [dictionary objectForKey:@"status_message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->activityIndicatorLoader stopAnimating];
                self->activityIndicatorLoader.hidden = YES;
                [self ShowToast:strErrorMsg];
             });
            
        }else{
            if(httpResponse.statusCode == 200){
                
                self->movieListArray = [dictionary objectForKey:@"results"];
                
                [self->duplicatemovieListArray addObjectsFromArray:self->movieListArray];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityIndicatorLoader stopAnimating];
                    self->activityIndicatorLoader.hidden = YES;

                    [self->tblMoviesList reloadData];
                 });
                
            }else{
                NSString *strErrorMsg = [dictionary objectForKey:@"status_message"];
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


#pragma mark -Table view delegate Events-

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblMoviesList) {
        
        return movieListArray.count;
    }else{
        
        return recentlySearchArray.count;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == tblMoviesList) {
        
        return 165.0f;
        
    }else{
        
        return 30.0f;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblMoviesList) {
        
        MovieInfoTableViewCell *cell = (MovieInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell){
            NSArray *objects =  [[NSBundle mainBundle] loadNibNamed:@"MovieInfoTableViewCell" owner:self options:nil];
                
            for (id topObj in objects) {
                if ([topObj isKindOfClass:[UITableViewCell class]]) {
                    cell = (MovieInfoTableViewCell *) topObj;
                    break;
                }
            }
        }
        
        NSString *strFormatedDate = [self formatedDate: [[movieListArray objectAtIndex:indexPath.row] objectForKey:@"release_date"]];
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // retrive image on global queue
            
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
            NSString *strImageURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ImageURL"]];
        
            NSString *URLStr = [NSString stringWithFormat:@"%@%@",strImageURL, [[self->movieListArray objectAtIndex:indexPath.row] objectForKey:@"poster_path"]];

            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLStr]];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [imageData isEqual:[NSNull null]] || [imageData isKindOfClass:[NSNull class]] || imageData.length == 0) {
                    
                    cell.imgBanner.image = [UIImage imageNamed:@"poster-placeholder.png"];
                    
                }else{
                    
                    cell.imgBanner.image = [UIImage imageWithData: imageData];
                    
                }
            });
        });
        
        cell.lblMovieTitle.text = [[movieListArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.lblReleaseDate.text = strFormatedDate;
        cell.lblOtherDetails.text = [[movieListArray objectAtIndex:indexPath.row] objectForKey:@"overview"];
        
        return cell;
        
    }else{
        
        static NSString *tableIdencetifier = @"TableItem";
     
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdencetifier];
     
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdencetifier];
        }
     
        cell.textLabel.text = [[recentlySearchArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView == tblMoviesList) {
        
        if (isSearchedMovie) {
            if (recentlySearchArray.count > 4) {
                
                [recentlySearchArray removeLastObject];
                [recentlySearchArray addObject:[movieListArray objectAtIndex:indexPath.row]];
            }else{
                [recentlySearchArray addObject:[movieListArray objectAtIndex:indexPath.row]];
            }
            
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            MovieDetailsViewController *view = [[MovieDetailsViewController alloc]initWithNibName:@"MovieDetailsViewController" bundle:[NSBundle mainBundle]];
            view.strMovieID = [[self->movieListArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            [self.navigationController pushViewController:view animated:NO];
        });
        
    }else{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            MovieDetailsViewController *view = [[MovieDetailsViewController alloc]initWithNibName:@"MovieDetailsViewController" bundle:[NSBundle mainBundle]];
            view.strMovieID = [[self->recentlySearchArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            [self.navigationController pushViewController:view animated:NO];
        });
        
    }

}




#pragma mark - UISearchBar Delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (recentlySearchArray.count > 0) {
        
        recentlySearchedView.hidden = NO;
        [tblRecentlySearchedList reloadData];
    }

    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar TextDidBeginEditing:(NSString *)searchText
{
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{   isSearchedMovie = NO;
    [searchBar resignFirstResponder];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->tblMoviesList reloadData];
        self->recentlySearchedView.hidden = YES;
    });
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
  
    if(searchText.length == 0){
        isSearchedMovie = NO;
        if (recentlySearchArray.count > 0) {
            
            recentlySearchedView.hidden = NO;
            [tblRecentlySearchedList reloadData];
        }
        movieListArray = [[NSMutableArray alloc]initWithArray:duplicatemovieListArray];
     
    }else{
        isSearchedMovie = YES;
        recentlySearchedView.hidden = YES;
        [filterArray removeAllObjects];
        
        for (int i = 0; i < [duplicatemovieListArray count]; i++){
            
            NSString *strTitle = [[[duplicatemovieListArray objectAtIndex:i] objectForKey:@"title"] lowercaseString];
            
           if([strTitle rangeOfString:[searchText lowercaseString]].length > 0){
               
               if (searchText.length == 1) {
                   NSString *strTitleFirstLetter = [strTitle substringToIndex:1];
                   
                   if ([strTitleFirstLetter isEqualToString:[searchText lowercaseString]]) {
                       [filterArray addObject:[duplicatemovieListArray objectAtIndex:i]];
                   }
                   
               }else{
                   [filterArray addObject:[duplicatemovieListArray objectAtIndex:i]];
               }
           }
       }
        
        movieListArray = [NSMutableArray arrayWithArray:filterArray];

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->tblMoviesList reloadData];
    });
 }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isSearchedMovie = NO;
    [searchBar resignFirstResponder];
    recentlySearchedView.hidden = YES;
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
@end

