import Foundation
import Alamofire

//
// Created by John Singer on 7.23.17
//

print("Hello, world!")

class JSSAPI {
    
    private var api: String
    private var auth: String
    
    init(serverURL: String, jamfUsername: String, jamfPassword: String) {
        self.api = "https://\(serverURL)/JSSResource"
        self.auth = "\(jamfUsername):\(jamfPassword)".dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    func getComputerRecord(serialNumber: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: (NSURL(string: "\(api)/computers/match/" + serialNumber ))!)
        request.HTTPMethod = "GET"
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }


    func createPlaceholder(serialNumber: String, macAddress: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let xml = "<computer>" +
                    "<general>" +
                        "<name>Placeholder-\(serialNumber)</name>" +
                        "<serial_number>\(serialNumber)</serial_number>" +
                        "<mac_address>\(macAddress)</mac_address>" +
                    "</general>" +
                "</computer>"
        
        let request = NSMutableURLRequest(URL: (NSURL(string: "\(api)/computers/id/0"))!)
        request.HTTPMethod = "POST"
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        request.HTTPBody = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    func addComputerToGroup(serialNumber: String, groupName: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let xml = "<computer_group>" +
                    "<computer_additions>" +
                        "<computer>" +
                            "<serial_number>\(serialNumber)</serial_number>" +
                        "</computer>" +
                    "</computer_additions>" +
                "</computer_group>"
        
        let urlEncodedGroupName = groupName.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let request = NSMutableURLRequest(URL: (NSURL(string: "\(api)/computergroups/name/\(urlEncodedGroupName)"))!)
        request.HTTPMethod = "PUT"
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        request.HTTPBody = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    func removeComputerFromGroup(serialNumber: String, groupName: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let xml = "<computer_group>" +
                    "<computer_deletions>" +
                        "<computer>" +
                            "<serial_number>\(serialNumber)</serial_number>" +
                        "</computer>" +
                    "</computer_deletions>" +
                "</computer_group>"
        
        let urlEncodedGroupName = groupName.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let request = NSMutableURLRequest(URL: (NSURL(string: "\(api)/computergroups/name/\(urlEncodedGroupName)"))!)
        request.HTTPMethod = "PUT"
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        request.HTTPBody = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    func getGroups(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: (NSURL(string: "\(api)/computergroups"))!)
        request.HTTPMethod = "GET"
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
}
