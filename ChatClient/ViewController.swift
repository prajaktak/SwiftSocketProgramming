//
//  ViewController.swift
//  ChatClient
//
//  Created by Prajakta Kulkarni on 10/1/16.
//  Copyright © 2016 Prajakta Kulkarni. All rights reserved.
//

import UIKit

class ViewController: UIViewController,StreamDelegate{
    var inputStream:InputStream!
    var outputStream:OutputStream!
    
    @IBOutlet weak var inputNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initNetworkCommunication()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func joinChat(_ sender: UIButton) {
//        let response:NSString = NSString.localizedStringWithFormat("i am :%@", inputNameField.text!)
//        let adata :Data = response.data(using: String.Encoding.ascii.rawValue)!
//        outputStream.write(adata., maxLength: adata.length)
//        
//    }
//    - (IBAction)joinChat:(id)sender {
//    
//    NSString *response  = [NSString stringWithFormat:@"iam:%@", inputNameField.text];
//    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
//    [outputStream write:[data bytes] maxLength:[data length]];
//    
//    }
    
    func initNetworkCommunication()
    {
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, "localhost" as CFString, 80, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.delegate = self
        outputStream.delegate =  self
        
        
        var currentRunLoop: RunLoop?
        
        inputStream.schedule(in: currentRunLoop!, forMode:RunLoopMode.defaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
    }
    
    @IBAction func joinChat(_ sender: UIButton) {
    }


}

