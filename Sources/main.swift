//#! /usr/bin/swift

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

let pattern = "f:u:p:"
var fFlag = false
var fVal: String?

var uFlag = false
var uValue: String?

var pFlag = false
var pValue: String?

let url = "https://casper.csueastbay.edu:8443/JSSResource/"
var headers: HTTPHeaders = [
    "Accept": "application/json"
]
// Usage: QueryCasper -f json_authorization_file.txt -p sub_url or
//        QueryCasper -u username:password -p sub_url 
// NOTE: -f & -u are mutually-exclusive

while case let option = getopt(CommandLine.argc, CommandLine.unsafeArgv, pattern), option != -1 {
    switch UnicodeScalar(CUnsignedChar(option)) {
    case "u":
        uFlag = true
        uValue = String(cString: optarg)
        
    case "f":
        fFlag = true
        fVal = String(cString: optarg)
        
    case "p":
        pFlag = true
        pValue = String(cString: optarg)
        
    default:
//        fatalError("Unknown option")
        print("Unknown Option: \(CommandLine.arguments[0])")
        exit(EXIT_FAILURE)
    }
}

// the following is the same thing as a logical XOR
guard  uFlag != fFlag else {
    print("-u or -f, Either command-line flag option may be used; not both")
    exit(EXIT_FAILURE)
}


print("fFlag = \(fFlag) and fValue = ", fVal ?? "?")
print("uFlag = \(uFlag) and uValue = ", uValue ?? "?", "\n")
print("pFlag = \(pFlag) and pValue = ", pValue ?? "?", "\n")

// Now, if the fFlag is set, we've gotten our parameter file from the command-line, so we'll try to read it, parse, it and
//    use it to access JAMF.
if fFlag {
    do {
        var filedata = try String(contentsOfFile: fVal!, encoding: String.Encoding.utf8)

        if let authProps = filedata.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: authProps)
            let user = json["username"].string
            let password = json["password"].string
            
            if let authorizationHeader = Request.authorizationHeader(user: user!, password: password!) {
                headers[authorizationHeader.key] = authorizationHeader.value
            }
            
            print("headers: \(headers)")
            let r = Alamofire.request(url+pValue!, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
            }
            debugPrint(r)
        }
   }
}

