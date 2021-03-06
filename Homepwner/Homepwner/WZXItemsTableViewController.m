//
//  WZXItemsTableViewController.m
//  Homepwner
//
//  Created by wayne on 14-3-24.
//  Copyright (c) 2014年 wayne. All rights reserved.
//

#import "WZXItemsTableViewController.h"
#import "Item.h"
#import "ItemStore.h"
#import "ItemDetailVC.h"
#import "ImagePopoverViewController.h"
#import "ImageStore.h"
#import "ItemCell.h"

@interface WZXItemsTableViewController ()<UIPopoverControllerDelegate>
@property (nonatomic,strong)IBOutlet UIView *headerView;
@property (nonatomic,strong) UIPopoverController *popController;
@end

@implementation WZXItemsTableViewController
-(instancetype)init
{
    self=[super initWithStyle:UITableViewStylePlain];
    if(self){
//        for(int i=0;i<5;i++){
//            [[ItemStore sharedStore] addStoreItem];
//        }
        UINavigationItem *item=self.navigationItem;
        item.title=@"wayne";
        UIBarButtonItem *barButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(addNewItem:)];
        item.leftBarButtonItem=barButton;
        item.rightBarButtonItem=self.editButtonItem;
        NSNotificationCenter *defaultCenter=[NSNotificationCenter defaultCenter];
        [self updateTableSize];
        [defaultCenter addObserver:self
                          selector:@selector(updateTableSize)
                              name:UIContentSizeCategoryDidChangeNotification
                            object:nil];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //注册cell，让table在初始化cell的时候知道去找那种样子的cell
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseCell"];
    UINib *itemCell=[UINib nibWithNibName:@"ItemCell" bundle:nil];
    [self.tableView registerNib:itemCell
         forCellReuseIdentifier:@"reuseCell"];
    
//    UIView *header=self.headerView;
//    [self.tableView setTableHeaderView:header];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
 
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    // Return the number of rows in the section.
    return [[[ItemStore sharedStore] allItems] count];
}
//-(UIView *)headerView
//{
//    if(!_headerView){
//        [[NSBundle mainBundle] loadNibNamed:@"HeaderView"
//                                      owner:self
//                                    options:nil];
//    }
//    return _headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置cell的内容
//    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"reuseCell" forIndexPath:indexPath];
    ItemCell *cell=[tableView dequeueReusableCellWithIdentifier:@"reuseCell"
                                                   forIndexPath:indexPath];
    NSArray *allItems=[[ItemStore sharedStore] allItems];
    Item *item=allItems[indexPath.row];
//    cell.textLabel.text=[item description];
//    cell.itemImage.image=item.itemImage;
    cell.itemName.text=item.name;
    cell.itemSerial.text=item.serial;
    cell.itemValue.text=[NSString stringWithFormat:@"%d",item.value];
    cell.thumbImage.image=item.thumbnail;
    //give the block a weak reference to the cell
    __weak ItemCell *weakCell=cell;
    cell.tapButton=^(){
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        {
            NSDictionary *imageDictionary=[[ImageStore sharedImage] getImageArray];
            UIImage *image=[imageDictionary objectForKey:item.key];
            if(!image){
                return ;
            }
            //covert the thumbnail frame to the tableview frame
            //so that the popover next know where to triger
            CGRect rect=[self.view convertRect:weakCell.thumbImage.bounds fromView:weakCell.thumbImage];
            ImagePopoverViewController *popover=[[ImagePopoverViewController alloc] init];
            popover.image=image;
            self.popController=[[UIPopoverController alloc] initWithContentViewController:popover];
            self.popController.delegate=self;
            self.popController.popoverContentSize=CGSizeMake(400,400);
            [self.popController presentPopoverFromRect:rect
                                                inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
    
    };
    return cell;
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popController=nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ItemDetailVC *detailVC=[[ItemDetailVC alloc] initForBool:NO];
    NSArray *allItems=[[ItemStore sharedStore] allItems];
    detailVC.item=allItems[indexPath.row];
    [self.navigationController pushViewController:detailVC
                                         animated:YES
     ];
}
//-(IBAction)toggleEdit:(id)sender
//{
//    if(self.isEditing){
//        [sender setTitle:@"Edit" forState:UIControlStateNormal];
//        [self setEditing:NO animated:YES];
//    }
//    else{
//        [sender setTitle:@"Done" forState:UIControlStateNormal];
//        [self setEditing:YES animated:YES];
//    }
//}
-(IBAction)addNewItem:(id)sender
{
    //create new item
    Item *newItem=[[ItemStore sharedStore] addStoreItem];
    //his position
//    NSInteger hisRow=[[[ItemStore sharedStore] allItems] indexOfObject:newItem];
    //find his indexpath
//    NSIndexPath *newItemPath=[NSIndexPath indexPathForRow:hisRow inSection:0];
    //insert into table
    //indexpath include the info of row index and section index
//    [self.tableView insertRowsAtIndexPaths:@[newItemPath] withRowAnimation:UITableViewRowAnimationLeft];
    ItemDetailVC *detail=[[ItemDetailVC alloc] initForBool:YES];
    detail.item=newItem;
    detail.dismiss=^{
        [self.tableView reloadData];
    };
    UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:detail];
    navController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    navController.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *allItems=[[ItemStore sharedStore] allItems];
        Item *removeItem=allItems[indexPath.row];
        [[ItemStore sharedStore] removeStoreItem:removeItem];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ItemStore sharedStore] moveItemPositon:fromIndexPath.row to:toIndexPath.row];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - update size
-(void)updateTableSize
{
    static NSDictionary *sizeDictionary;
    if(!sizeDictionary){
        sizeDictionary=@{
                         UIContentSizeCategoryExtraSmall:@44,
                         UIContentSizeCategorySmall:@44,
                         UIContentSizeCategoryMedium:@44,
                         UIContentSizeCategoryLarge:@44,
                         UIContentSizeCategoryExtraLarge:@55,
                         UIContentSizeCategoryExtraExtraLarge:@65,
                         UIContentSizeCategoryExtraExtraExtraLarge:@75
        };
    }
    
    NSString *userSize=[[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *rowHeight=sizeDictionary[userSize];
    [self.tableView setRowHeight:[rowHeight floatValue]];
    [self.tableView reloadData];
}

@end
