//
//  MovieDetailsViewController.h
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

@interface MovieDetailsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    NSDictionary *movieDetailsDict;
    NSArray *movieCastArray;
    NSArray *movieCrewArray;
    NSArray *similarMoviesArray;
}

@property(nonatomic,retain) NSString *strMovieID;
@property(strong, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property(strong, nonatomic) IBOutlet UILabel *lblReleaseDate;
@property(strong, nonatomic) IBOutlet UILabel *lblLanguage;
@property(strong, nonatomic) IBOutlet UILabel *lblGenre;
@property(strong, nonatomic) IBOutlet UILabel *lblOverview;
@property(strong, nonatomic) IBOutlet UILabel *lblCast;
@property(strong, nonatomic) IBOutlet UIImageView *imgBanner;
@property(strong, nonatomic) IBOutlet UICollectionView *collectionViewCast;
@property(strong, nonatomic) IBOutlet UICollectionView *collectionViewCrew;
@property(strong, nonatomic) IBOutlet UICollectionView *collectionViewSimilarMovies;
@property(strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorLoader;

@end

NS_ASSUME_NONNULL_END
