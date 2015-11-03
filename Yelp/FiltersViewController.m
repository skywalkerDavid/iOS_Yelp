//
//  FiltersViewController.m
//  Yelp
//
//  Created by David Wang on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchViewCell.h"
#import "OptionCell.h"
#import "YelpClient.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) BOOL isDeal;
@property (nonatomic, assign) YelpSortMode sortMode;
@property (nonatomic, strong) NSArray *distanceArray;
@property (nonatomic, strong) NSArray *sortArray;
@property (nonatomic, strong) NSIndexPath *sortSelectedIndex;
@property (nonatomic, strong) NSIndexPath *distanceSelectedIndex;
@end

@implementation FiltersViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
    }
    
    self.distanceArray = @[@"Auto", @"0.3 mile", @"1 mile", @"5 miles", @"20 miles"];
    self.sortArray = @[@"Best Matched", @"Distance", @"Highest Rated"];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButtonTapped)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchViewCell" bundle:nil] forCellReuseIdentifier:@"SwitchViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionCell" bundle:nil] forCellReuseIdentifier:@"OptionCell"];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        
        [filters setObject:names forKey:@"category_filter"];
    }
    
    NSNumber *isDealNumber = [NSNumber numberWithBool:self.isDeal];
    [filters setObject:isDealNumber forKey:@"deals_filter"];
    
    NSNumber *sortModeNumber = [NSNumber numberWithInt:self.sortMode];
    [filters setObject:sortModeNumber forKey:@"sort"];
    
    return filters;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.sortArray.count;
        case 2:
            return self.distanceArray.count;
        case 3:
            return self.categories.count;
        default:
            return self.categories.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SwitchViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchViewCell"];
        cell.titleLabel.text = @"Offering a Deal";
        cell.on = self.isDeal;
        
        return cell;
    }
    
    if (indexPath.section == 1) {
        OptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
        cell.nameLabel.text = self.sortArray[indexPath.row];
        
        if (!self.sortSelectedIndex) {
            self.sortSelectedIndex = indexPath;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            if ([indexPath isEqual:self.sortSelectedIndex]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        return cell;
    }

    if (indexPath.section == 2) {
        OptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
        cell.nameLabel.text = self.distanceArray[indexPath.row];
        
        if (!self.distanceSelectedIndex) {
            self.distanceSelectedIndex = indexPath;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            if ([indexPath isEqual:self.distanceSelectedIndex]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        return cell;
    }
    
    if (indexPath.section == 3) {
        SwitchViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchViewCell"];
    
        cell.titleLabel.text = self.categories[indexPath.row][@"name"];
        cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
        cell.delegate = self;
    
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                self.sortMode = YelpSortModeBestMatched;
                break;
            case 1:
                self.sortMode = YelpSortModeDistance;
                break;
            case 2:
                self.sortMode = YelpSortModeHighestRated;
                break;
            default:
                break;
        }
        
        if (![self.sortSelectedIndex isEqual:indexPath]) {
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *deselectedCell = [tableView cellForRowAtIndexPath:self.sortSelectedIndex];
            deselectedCell.accessoryType = UITableViewCellAccessoryNone;
            
            self.sortSelectedIndex = indexPath;
        }
    }
    
    if (indexPath.section == 2) {
        if (![self.distanceSelectedIndex isEqual:indexPath]) {
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *deselectedCell = [tableView cellForRowAtIndexPath:self.distanceSelectedIndex];
            deselectedCell.accessoryType = UITableViewCellAccessoryNone;
            
            self.distanceSelectedIndex = indexPath;
        }
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 1:
            sectionName = @"Sort By";
            break;
        case 2:
            sectionName = @"Distance";
            break;
        case 3:
            sectionName = @"Categories";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (void) switchCell:(SwitchViewCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (value) {
        [self.selectedCategories addObject:self.categories[indexPath.row]];
    } else {
        [self.selectedCategories removeObject:self.categories[indexPath.row]];
    }
}


#pragma mark - private method

- (void)onCancelButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButtonTapped {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.categories = @[@{@"name": @"Afghan", @"code": @"afghani"},
                        @{@"name": @"African", @"code": @"african"},
                        @{@"name": @"American, New", @"code": @"newamerican"},
                        @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                        @{@"name": @"Arabian", @"code": @"arabian"},
                        @{@"name": @"Argentine", @"code": @"argentine"},
                        @{@"name": @"Armenian", @"code": @"armenian"},
                        @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                        @{@"name": @"Asturian", @"code": @"asturian"},
                        @{@"name": @"Australian", @"code": @"australian"},
                        @{@"name": @"Austrian", @"code": @"austrian"},
                        @{@"name": @"Baguettes", @"code": @"baguettes"},
                        @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                        @{@"name": @"Barbeque", @"code": @"bbq"},
                        @{@"name": @"Basque", @"code": @"basque"},
                        @{@"name": @"Bavarian", @"code": @"bavarian"},
                        @{@"name": @"Beer Garden", @"code": @"beergarden"},
                        @{@"name": @"Beer Hall", @"code": @"beerhall"},
                        @{@"name": @"Beisl", @"code": @"beisl"},
                        @{@"name": @"Belgian", @"code": @"belgian"},
                        @{@"name": @"Bistros", @"code": @"bistros"},
                        @{@"name": @"Black Sea", @"code": @"blacksea"},
                        @{@"name": @"Brasseries", @"code": @"brasseries"},
                        @{@"name": @"Brazilian", @"code": @"brazilian"},
                        @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                        @{@"name": @"British", @"code": @"british"},
                        @{@"name": @"Buffets", @"code": @"buffets"},
                        @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                        @{@"name": @"Burgers", @"code": @"burgers"},
                        @{@"name": @"Burmese", @"code": @"burmese"},
                        @{@"name": @"Cafes", @"code": @"cafes"},
                        @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                        @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                        @{@"name": @"Cambodian", @"code": @"cambodian"},
                        @{@"name": @"Canadian", @"code": @"New)"},
                        @{@"name": @"Canteen", @"code": @"canteen"},
                        @{@"name": @"Caribbean", @"code": @"caribbean"},
                        @{@"name": @"Catalan", @"code": @"catalan"},
                        @{@"name": @"Chech", @"code": @"chech"},
                        @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                        @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                        @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                        @{@"name": @"Chilean", @"code": @"chilean"},
                        @{@"name": @"Chinese", @"code": @"chinese"},
                        @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                        @{@"name": @"Corsican", @"code": @"corsican"},
                        @{@"name": @"Creperies", @"code": @"creperies"},
                        @{@"name": @"Cuban", @"code": @"cuban"},
                        @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                        @{@"name": @"Cypriot", @"code": @"cypriot"},
                        @{@"name": @"Czech", @"code": @"czech"},
                        @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                        @{@"name": @"Danish", @"code": @"danish"},
                        @{@"name": @"Delis", @"code": @"delis"},
                        @{@"name": @"Diners", @"code": @"diners"},
                        @{@"name": @"Dumplings", @"code": @"dumplings"},
                        @{@"name": @"Eastern European", @"code": @"eastern_european"},
                        @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                        @{@"name": @"Fast Food", @"code": @"hotdogs"},
                        @{@"name": @"Filipino", @"code": @"filipino"},
                        @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                        @{@"name": @"Fondue", @"code": @"fondue"},
                        @{@"name": @"Food Court", @"code": @"food_court"},
                        @{@"name": @"Food Stands", @"code": @"foodstands"},
                        @{@"name": @"French", @"code": @"french"},
                        @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                        @{@"name": @"Galician", @"code": @"galician"},
                        @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                        @{@"name": @"Georgian", @"code": @"georgian"},
                        @{@"name": @"German", @"code": @"german"},
                        @{@"name": @"Giblets", @"code": @"giblets"},
                        @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                        @{@"name": @"Greek", @"code": @"greek"},
                        @{@"name": @"Halal", @"code": @"halal"},
                        @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                        @{@"name": @"Heuriger", @"code": @"heuriger"},
                        @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                        @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                        @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                        @{@"name": @"Hot Pot", @"code": @"hotpot"},
                        @{@"name": @"Hungarian", @"code": @"hungarian"},
                        @{@"name": @"Iberian", @"code": @"iberian"},
                        @{@"name": @"Indian", @"code": @"indpak"},
                        @{@"name": @"Indonesian", @"code": @"indonesian"},
                        @{@"name": @"International", @"code": @"international"},
                        @{@"name": @"Irish", @"code": @"irish"},
                        @{@"name": @"Island Pub", @"code": @"island_pub"},
                        @{@"name": @"Israeli", @"code": @"israeli"},
                        @{@"name": @"Italian", @"code": @"italian"},
                        @{@"name": @"Japanese", @"code": @"japanese"},
                        @{@"name": @"Jewish", @"code": @"jewish"},
                        @{@"name": @"Kebab", @"code": @"kebab"},
                        @{@"name": @"Korean", @"code": @"korean"},
                        @{@"name": @"Kosher", @"code": @"kosher"},
                        @{@"name": @"Kurdish", @"code": @"kurdish"},
                        @{@"name": @"Laos", @"code": @"laos"},
                        @{@"name": @"Laotian", @"code": @"laotian"},
                        @{@"name": @"Latin American", @"code": @"latin"},
                        @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                        @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                        @{@"name": @"Malaysian", @"code": @"malaysian"},
                        @{@"name": @"Meatballs", @"code": @"meatballs"},
                        @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                        @{@"name": @"Mexican", @"code": @"mexican"},
                        @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                        @{@"name": @"Milk Bars", @"code": @"milkbars"},
                        @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                        @{@"name": @"Modern European", @"code": @"modern_european"},
                        @{@"name": @"Mongolian", @"code": @"mongolian"},
                        @{@"name": @"Moroccan", @"code": @"moroccan"},
                        @{@"name": @"New Zealand", @"code": @"newzealand"},
                        @{@"name": @"Night Food", @"code": @"nightfood"},
                        @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                        @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                        @{@"name": @"Oriental", @"code": @"oriental"},
                        @{@"name": @"Pakistani", @"code": @"pakistani"},
                        @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                        @{@"name": @"Parma", @"code": @"parma"},
                        @{@"name": @"Persian/Iranian", @"code": @"persian"},
                        @{@"name": @"Peruvian", @"code": @"peruvian"},
                        @{@"name": @"Pita", @"code": @"pita"},
                        @{@"name": @"Pizza", @"code": @"pizza"},
                        @{@"name": @"Polish", @"code": @"polish"},
                        @{@"name": @"Portuguese", @"code": @"portuguese"},
                        @{@"name": @"Potatoes", @"code": @"potatoes"},
                        @{@"name": @"Poutineries", @"code": @"poutineries"},
                        @{@"name": @"Pub Food", @"code": @"pubfood"},
                        @{@"name": @"Rice", @"code": @"riceshop"},
                        @{@"name": @"Romanian", @"code": @"romanian"},
                        @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                        @{@"name": @"Rumanian", @"code": @"rumanian"},
                        @{@"name": @"Russian", @"code": @"russian"},
                        @{@"name": @"Salad", @"code": @"salad"},
                        @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                        @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                        @{@"name": @"Scottish", @"code": @"scottish"},
                        @{@"name": @"Seafood", @"code": @"seafood"},
                        @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                        @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                        @{@"name": @"Singaporean", @"code": @"singaporean"},
                        @{@"name": @"Slovakian", @"code": @"slovakian"},
                        @{@"name": @"Soul Food", @"code": @"soulfood"},
                        @{@"name": @"Soup", @"code": @"soup"},
                        @{@"name": @"Southern", @"code": @"southern"},
                        @{@"name": @"Spanish", @"code": @"spanish"},
                        @{@"name": @"Steakhouses", @"code": @"steak"},
                        @{@"name": @"Sushi Bars", @"code": @"sushi"},
                        @{@"name": @"Swabian", @"code": @"swabian"},
                        @{@"name": @"Swedish", @"code": @"swedish"},
                        @{@"name": @"Swiss Food", @"code": @"swissfood"},
                        @{@"name": @"Tabernas", @"code": @"tabernas"},
                        @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                        @{@"name": @"Tapas Bars", @"code": @"tapas"},
                        @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                        @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                        @{@"name": @"Thai", @"code": @"thai"},
                        @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                        @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                        @{@"name": @"Trattorie", @"code": @"trattorie"},
                        @{@"name": @"Turkish", @"code": @"turkish"},
                        @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                        @{@"name": @"Uzbek", @"code": @"uzbek"},
                        @{@"name": @"Vegan", @"code": @"vegan"},
                        @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                        @{@"name": @"Venison", @"code": @"venison"},
                        @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                        @{@"name": @"Wok", @"code": @"wok"},
                        @{@"name": @"Wraps", @"code": @"wraps"},
                        @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
}

@end
