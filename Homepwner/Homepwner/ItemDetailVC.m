//
//  ItemDetailVC.m
//  Homepwner
//
//  Created by wayne on 14-3-26.
//  Copyright (c) 2014年 wayne. All rights reserved.
//

#import "ItemDetailVC.h"
#import "Item.h"
#import "ImageStore.h"
#import "ItemStore.h"

@interface ItemDetailVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *serial;
@property (weak, nonatomic) IBOutlet UITextField *value;
@property (weak, nonatomic) IBOutlet UILabel *data;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong,nonatomic) UIPopoverController *popover;
@end

@implementation ItemDetailVC
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"init fail"
                                   reason:@"you should use initForBool"
                                 userInfo:nil];
}
-(instancetype)initForBool:(BOOL)modal
{
    self=[super initWithNibName:nil bundle:nil];
    if(self){
        if(modal){
            UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(saveNewItem)];
            self.navigationItem.rightBarButtonItem=doneButton;
            UIBarButtonItem *cancelButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancelButton)];
            self.navigationItem.leftBarButtonItem=cancelButton;
        }
    }
    return self;
}
-(void)saveNewItem
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismiss];
    return ;
}
-(void)cancelButton
{
    ItemStore *itemStore=[ItemStore sharedStore];
    [itemStore removeStoreItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                       completion:self.dismiss
     ];
    return;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    Item *item=self.item;
    self.name.text=item.itemName;
    self.serial.text=item.serialNumber;
    self.value.text=[NSString stringWithFormat:@"%d",item.valueInDollars];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    self.data.text=[dateFormatter stringFromDate:[NSDate date]];
    UIInterfaceOrientation io=[self interfaceOrientation];
    [self checkOrientataionAndDevice:io];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *image=[[UIImageView alloc] initWithImage:nil];
    image.contentMode=UIViewContentModeScaleAspectFit;
    image.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:image];
    self.image=image;
    Item *item=self.item;
    if(item.itemImage){
        self.image.image=item.itemImage;
    }
    [self.image setContentHuggingPriority:200
                                      forAxis:UILayoutConstraintAxisVertical];
    [self.image setContentCompressionResistancePriority:700
                                      forAxis:UILayoutConstraintAxisVertical];
    NSDictionary *mapView=@{@"image":self.image,
                            @"label":self.data,
                            @"toolbar":self.toolBar};
    NSArray *horizontalConstraint=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]-0-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:mapView];
    NSArray *verticalConstraint=[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-8-[image]-8-[toolbar]"
                                                                        options:0
                                                                        metrics:nil
                                                                       views:mapView];
    [self.view addConstraints:horizontalConstraint];
    [self.view addConstraints:verticalConstraint];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    Item *item=self.item;
    item.itemName=self.name.text;
    item.serialNumber=self.serial.text;
    item.valueInDollars=[self.value.text intValue];
    if(self.image.image){
        ImageStore *imageStore=[ImageStore sharedImage];
        [imageStore addImage:self.image.image
                      forKey:item.uniqueKey];
    }
    
}
-(void)setItem:(Item *)item{
    _item=item;
    self.navigationItem.title=item.itemName;
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"im being dismissed");
    self.popover=nil;
}
- (IBAction)takePhoto:(id)sender {
    if([self.popover isPopoverVisible]){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
        return;
    }
    UIImagePickerController *imagePC=[[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePC.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    else{
        imagePC.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePC.delegate=self;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad){
        self.popover=[[UIPopoverController alloc] initWithContentViewController:imagePC];
        self.popover.delegate=self;
        [self.popover presentPopoverFromBarButtonItem:sender
                                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                                       animated:YES];
    }
    else{
        [self presentViewController:imagePC
                           animated:YES
                         completion:nil];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    self.image.image=image;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
    else{
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}
- (IBAction)backgroundClick:(id)sender {
    [self.view endEditing:YES];
}
-(void)viewDidLayoutSubviews
{
    for (UIView *view in self.view.subviews){
        if([view hasAmbiguousLayout]){
            NSLog(@"ambiguous:%@",view);
        }
    }
}
-(void)checkOrientataionAndDevice:(UIInterfaceOrientation) orientation
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        return;
    }
    if(UIInterfaceOrientationIsLandscape(orientation)){
        self.image.hidden=YES;
        self.cameraButton.enabled=NO;
    }
    else{
        self.image.hidden=NO;
        self.cameraButton.enabled=YES;
    }
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self checkOrientataionAndDevice:toInterfaceOrientation];
}
@end
