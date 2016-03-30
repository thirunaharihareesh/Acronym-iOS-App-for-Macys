//
//  ViewController.m
//  AcronymAppForMacys
//
//  Created by Hareesh Thirunahari on 3/30/16.
//  Copyright © 2016 Hareesh Thirunahari. All rights reserved.
//



#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TableCell.h"

static NSString * const BASE_URL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";



@interface ViewController ()


- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *resultsLBL;

@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (strong, nonatomic) NSMutableArray * resultsArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_searchTF setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.resultsTableView.dataSource=self;
    self.resultsTableView.delegate=self;
    self.resultsTableView.hidden=false;
    self.resultsTableView.tableFooterView=[[UIView alloc ] init];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellTobeReused = @"resultCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellTobeReused];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTobeReused];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
       cell.textLabel.text = ((TableCell *)[self.resultsArray objectAtIndex:indexPath.row]).labelText;
    cell.detailTextLabel.text = ((TableCell *)[self.resultsArray objectAtIndex:indexPath.row]).detailLabelText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsArray count];
}

- (IBAction)search:(id)sender {
    if (self.searchTF.text != nil && [self.searchTF.text length] > 0) {
        
        
        
        [self.view endEditing:YES];
        //Using MBProgressHUD to show the progress
        [self.resultsArray removeAllObjects];
        MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        progressHUD.labelText = @"Pulling results";
        progressHUD.userInteractionEnabled = NO;
        
        self.resultsLBL.text = [@"Acronyms for: " stringByAppendingString:self.searchTF.text];
        
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
        [jsonAcceptableContentTypes addObject:@"text/plain"];
        jsonResponseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
        manager.responseSerializer = jsonResponseSerializer;
        [manager GET:BASE_URL parameters:@{@"sf": self.searchTF.text} success:^(AFHTTPRequestOperation * operation, id responseObject) {
            [self processResponseToBeShownInTheTable:responseObject];
            [self.resultsTableView reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.resultsTableView reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
        
    }
    
    
}

- (void) processResponseToBeShownInTheTable: (id) responseObject {
    NSArray * array = (NSArray *) responseObject;
    if (array.count > 0) {
        NSDictionary * dictionary = [array objectAtIndex:0];
        NSArray * innerArray = [dictionary objectForKey:@"lfs"];
        self.resultsArray = [[NSMutableArray alloc] init];
        TableCell * myTableCell = nil;
        if(innerArray != nil && innerArray.count > 0) {
            for(NSDictionary * dic in innerArray) {
                myTableCell = [[TableCell alloc] init];
                NSString * labelText = [dic objectForKey:@"lf"];
                NSString * detailLabelFirstPart = [dic objectForKey:@"freq"];
                NSString * detailLabelSecondPart = [dic objectForKey:@"since"];
                if(labelText != nil) {
                    myTableCell.labelText = labelText;
                    NSString *joinString=[NSString stringWithFormat:@"%@ %@ | %@ %@",@"Freq",detailLabelFirstPart, @"Since", detailLabelSecondPart];
                    myTableCell.detailLabelText = joinString;
                    [self.resultsArray addObject:myTableCell];
                    
                }
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)searchLabel {
    
    [self search:(_searchTF)];
    
    [searchLabel resignFirstResponder];
    return YES;
}

@end
