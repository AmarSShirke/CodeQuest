//
//  MoviesListViewController.h
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.
//

#import <UIKit/UIKit.h>
#import "APIRequestCall.h"
#define APIRequestCall [[APIRequestCall alloc]init]
#import "Network.h"
#define Network [[Network alloc]init]
#import "JSONParsing.h"
#define JSONParsing [[JSONParsing alloc]init]

NS_ASSUME_NONNULL_BEGIN

@interface MoviesListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    
    NSString *strAPIKey;
    NSMutableArray *movieListArray;
    NSMutableArray *duplicatemovieListArray;
    NSMutableArray *filterArray;
    NSMutableArray *recentlySearchArray;
    BOOL isSearchedMovie;
    
}

@property(strong, nonatomic) IBOutlet UITableView *tblMoviesList;
@property(strong, nonatomic) IBOutlet UITableView *tblRecentlySearchedList;
@property(strong, nonatomic) IBOutlet UISearchBar *movieSearchBar;
@property(strong, nonatomic) IBOutlet UIView *recentlySearchedView;
@property(strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorLoader;

@end

NS_ASSUME_NONNULL_END
