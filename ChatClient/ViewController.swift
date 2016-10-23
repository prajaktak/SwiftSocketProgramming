//
//  ViewController.swift
//  ChatClient
//
//  Created by Prajakta Kulkarni on 10/1/16.
//  Copyright © 2016 Prajakta Kulkarni. All rights reserved.
//

import UIKit

class ViewController: UIViewController,StreamDelegate,UITableViewDelegate,UITableViewDataSource{
    var inputStream:InputStream!
    var outputStream:OutputStream!
    var messages:NSMutableArray!
    
    enum sreamEnum {
        case rawValue
        case openCompleted
        case hasBytesAvailable
        case hasSpaceAvailable
        case errorOccurred
        case endEncountered
    }
    
    
    @IBOutlet weak var inputNameField: UITextField!

    @IBOutlet weak var inputMessageField: UITextField!
    @IBOutlet weak var tView: UITableView!
    @IBOutlet weak var chatView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initNetworkCommunication()
        messages = NSMutableArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func joinChat(_ sender: UIButton) {
        let response:NSString = NSString.localizedStringWithFormat("i am :%@", inputNameField.text!)
        let adata :Data = response.data(using: String.Encoding.ascii.rawValue)!
        let byteArray = [UInt8](adata)
        outputStream.write(byteArray, maxLength: adata.count)
        self.view .bringSubview(toFront: chatView)
        
    }
    
    func initNetworkCommunication()
    {
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, "localhost" as CFString, 88, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.delegate = self
        outputStream.delegate =  self
        
        inputStream.schedule(in: RunLoop.current, forMode:RunLoopMode.defaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            break
        case Stream.Event.hasBytesAvailable:
            if(aStream == inputStream)
            {
                let bufferSize = 1024
                var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
                
                while (inputStream.hasBytesAvailable) {
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if (len > 0) {
                        let output = NSString(bytes: &buffer, length: len, encoding: String.Encoding.ascii.rawValue)
                        if (nil != output) {
                            print("server says %@",output)
                            self.messagesReceived(message: output!)
                        }
                    }
                    
                }
            }
            break
        case Stream.Event.errorOccurred:
            break
        case Stream.Event.endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            break
        default:
            break
        }
    }
    
    func messagesReceived(message:NSString) {
        messages.add(message)
        self.tView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier:"chatCellIdentifier")
        tableViewCell.textLabel?.text = NSString(format:"%@",messages.object(at: indexPath.row) as! CVarArg) as String
        tableViewCell.textLabel?.textColor = .darkGray
        tableViewCell.textLabel?.textAlignment = .left
        return tableViewCell
        
    }
    

    @IBAction func sendMessage(_ sender: UIButton) {
        
        let response:NSString = NSString(format: "msg%@", inputMessageField.text!)
        let data:Data = response.data(using: String.Encoding.ascii.rawValue)!
        outputStream.write([UInt8](data), maxLength: data.count)
        inputMessageField.text = ""
    }
    
    

}

