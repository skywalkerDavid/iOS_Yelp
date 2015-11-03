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

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *selectedCategories;
@property (nonatomic, assign) BOOL isDeal;
@property (nonatomic, assign) YelpSortMode sortMode;

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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Filter" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:0.8f];
    [button.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    button.frame = CGRectMake(0.0, 100.0, 60.0, 28.0);
    [button addTarget:self action:@selector(onFitlersTapped)  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = filterButton;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.text = @"Resturants";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.searchBar setShowsCancelButton:NO];
        [self.searchBar resignFirstResponder];
    } else {
        [self.searchBar setShowsCancelButton:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length > 0) {
        [self fetchBusinessesWithQuery:searchBar.text sortMode:self.sortMode categories:self.selectedCategories deals:self.isDeal];
    }
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
    
    self.selectedCategories = filterDictionary[@"category_filter"];
    self.isDeal = [filterDictionary[@"deals_filter"] boolValue];
    self.sortMode = (YelpSortMode)[filterDictionary[@"sort"] intValue];
    
    [self fetchBusinessesWithQuery:@"Resturants" sortMode:self.sortMode categories:self.selectedCategories deals:self.isDeal];
}

@end
