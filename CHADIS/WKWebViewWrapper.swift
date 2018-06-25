////
////  WKWebViewWrapper.swift
////  CHADIS
////
////  Created by Paxon Yu on 6/25/18.
////  Copyright © 2018 Paxon Yu. All rights reserved.
////
//
//import Foundation
//import WebKit
//
//class WKWebViewWrapper : NSObject, WKScriptMessageHandler{
//    
//    var wkWebView : WKWebView
//    var eventFunctions : Dictionary<String, (String)->Void> = Dictionary<String, (String)->Void>()
//    var eventNames = ["onclick"]
//
//    
//    init(forWebView webView : WKWebView){
//        wkWebView = webView
//        super.init()
//    }
//    
//    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
//        
//        if let contentBody = message.body as? String{
//            if let eventFunction = eventFunctions[message.name]{
//                eventFunction(contentBody)
//            }
//        }
//        
//    }
//    
//    func setUpPlayerAndEventDelegation(){
//        
//        wkWebView.evaluateJavaScript("$(#tyler_durden_image).on('imagechanged', function(event, isSuccess) { window.webkit.messageHandlers.\(eventNames).postMessage(JSON.stringify(isSuccess)) }", completionHandler: nil)
//
//        
//        let controller = WKUserContentController()
//        wkWebView.configuration.userContentController = controller
//        
//        for eventname in eventNames {
//            controller.addScriptMessageHandler(self, name: eventname)
//            eventFunctions[eventname] = { _ in }
//
//        }
//    }
//}
