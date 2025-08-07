/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import Foundation
import CryptoSwift
import Logging


public class NobidLogger {
    private static var logger = Logger(label: "NobidLogger")

    public static func debug(_ message: String) {
        printMessage(message)
    }
    public static func taskSucceed(_ message: String) {
        printMessage(message, entryId: "TASK-SUCCESS")
    }
    public static func taskFailed(_ message: String) {
        printMessage(message, entryId: "TASK-FAILED")
    }
    public static func error(_ message: String) {
        printMessage("[ERROR] " + message)
    }
    public static func success(_ message: String) {
        printMessage("[SUCCESS] " + message)
    }
    public static func dump(_ message: String) {
        printMessage(message, entryId: "NOBID-DUMP")
    }
    static func printMessage(_ message: String, entryId: String = "STEP") {
        // <REF> https://github.com/apple/swift-log
        logger.info("\(message)", source: entryId)  // <C> source: this eliminates the extra [nobid] in log entry
    }

    public static func logResponse(subject: String, url: URL, data: Data, response: URLResponse) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        var responseHeaders = [String]()
        if let response = response as? HTTPURLResponse {
            let responseHeaders = response.allHeaderFields.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        }
        let text = """


>==============================================================================
>[NOBID][\(subject)] req.url=\(url)
<res.statusCode=\(statusCode)
<res.responseHeaders=\(responseHeaders)
<res.data.json.isValid=\(data.prettyPrintedJSONString() != nil)
<res.data.string=
\(String(data: data, encoding: .utf8) ?? "")
<res.data.raw=
\(data.map { String(format: "%02x", $0) }.joined())
<==============================================================================

"""
        logger.info("\(text)")

//        print("<==============================================================================")
//        print("<[NOBID][\(subject)] req.url=\(url)")
//        print(">res.statusCode=\(statusCode)")
//        print(">res.data.json=\(data.prettyPrintedJSONString())")
//        print(">res.data.raw=")
//        print(data.map { String(format: "%02x", $0) }.joined())
//        print(">==============================================================================")
    }
    
    public static func logRequest(subject: String, request: URLRequest) {
        let body = request.httpBody ?? Data()
        let url = request.url
        let headers = request.allHTTPHeaderFields ?? [:]
        let headersString = headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        let text = """


>==============================================================================
>[NOBID][\(subject)] req.url=\(url?.absoluteString ?? "")
>req.headers=\(headersString)
>req.body.json.isValid=\(body.prettyPrintedJSONString() != nil)
>req.body.string=\(String(data: body, encoding: .utf8) ?? "")
>req.body.raw=
\(body.map { String(format: "%02x", $0) }.joined())
>==============================================================================

"""
        logger.info("\(text)")
    }

    
    public static func logResponse(subject: String, request: URLRequest, data: Data, response: URLResponse) {
        let body = request.httpBody ?? Data()
        let url = request.url
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        var responseHeaders = [String]()
        if let response = response as? HTTPURLResponse {
            let responseHeaders = response.allHeaderFields.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        }
        let headersString = (request.allHTTPHeaderFields ?? [:]).map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        
        let text = """


>==============================================================================
>[NOBID][\(subject)] req.url=\(request.url?.absoluteString ?? "")
>req.headers=\(headersString)
>req.body.string=\(String(data: body, encoding: .utf8) ?? "")
>req.body.raw=
\(body.map { String(format: "%02x", $0) }.joined())
>- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
<[\(subject)] req.url=\(url?.absoluteString ?? "")
<res.statusCode=\(statusCode)
<res.responseHeaders=\(responseHeaders)
<res.data.json.isValid=\(data.prettyPrintedJSONString() != nil)
<res.data.string=
\(String(data: data, encoding: .utf8) ?? "")
<res.data.raw=
\(data.map { String(format: "%02x", $0) }.joined())
<==============================================================================

"""
        logger.info("\(text)")

//        print(">==============================================================================")
//        print(">[NOBID][\(subject)] req.url=\(request.url?.absoluteString ?? "")")
//        print(">req.body.json=\(body.prettyPrintedJSONString())")
//        print(">req.body.raw=")
//        print(body.map { String(format: "%02x", $0) }.joined())
//        print(">- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
//        print(">[\(subject)] req.url=\(url?.absoluteString ?? "")")
//        print("<res.statusCode=\(statusCode)")
//        print("<res.data.json=\(data.prettyPrintedJSONString())")
//        print("<res.data.raw=")
//        print(data.map { String(format: "%02x", $0) }.joined())
//        print("<==============================================================================")
    }
}
