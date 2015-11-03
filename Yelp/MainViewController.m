//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "YelpTableViewCell.h"
#import "FiltersViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *businesses;

- (void)fetchBusinessesWithQuery:(NSString *)term sortMode:(YelpSortMode)sortMode categories:(NSArray *)categories
 deals:(BOOL)hasDeal;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"YelpTableViewCell" bundle:nil] forCellReuseIdentifier:@"YelpTableViewCell"];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Yelp";
    
    UIBarButtonItem *fitlersItem = [[UIBarButtonItem alloc] initWithTitle:@"filters" style:UIBarButtonItemStylePlain target:self action:@selector(onFitlersTapped)];
    self.navigationItem.leftBarButtonItem = fitlersItem;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.text = @"Resturants";
    self.navigationItem.titleView = searchBar;
    
    [self fetchBusinessesWithQuery:@"Restaurants" sortMode:YelpSortModeBestMatched categories:nil deals:NO];
}

- (void)fetchBusinessesWithQuery:(NSString *)term sortMode:(YelpSortMode)sortMode categories:(NSArray *)categories
                           deals:(BOOL)hasDeal {
    
    [YelpBusiness searchWithTerm:term
                        sortMode:sortMode
                      categories:categories
                           deals:hasDeal
                      completion:^(NSArray *businesses, NSError *error) {
                          for (YelpBusiness *business in businesses) {
                              NSLog(@"%@", business);
                          }
                          self.businesses = businesses;
                          [self.tableView reloadData];
                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpTableViewCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

#pragma mark - private methods
- (void)onFitlersTapped {
    FiltersViewController *filterViewController = [[FiltersViewController alloc] init];
    filterViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filterViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)filtersViewController:(FiltersViewController *) filtersViewController didChangeFilters:(NSDictionary *) filterDictionary {
    NSLog(@"fire new filters changed event %@", filterDictionary);
    [self fetchBusinessesWithQuery:@"Resturants" sortMode:YelpSortModeBestMatched categories:filterDictionary[@"category_filter"] deals:NO];
}

@end
