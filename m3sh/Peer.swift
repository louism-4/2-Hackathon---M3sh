//
//  Peer.swift
//  m3sh
//
//  Created by Louis Moc on 2017-09-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Peer : NSObject, MCSessionDelegate {
    
    var peerID : MCPeerID
    var session : MCSession
    var advertiser : MCAdvertiserAssistant
    
    init(peerID : MCPeerID, session : MCSession, advertiser : MCAdvertiserAssistant){
        
        self.peerID = peerID
        self.session = session
        self.advertiser = advertiser
        
        super.init()
        self.session.delegate = self
    }
    
    func sessionSendData(_ data: Data)
    {
        var error: NSError?
        do {
            try self.session.send(data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            print("SENT PEER.swift")
        } catch {
            print(error)
        }
    }
    
    func advertiserStart(){
        advertiser.start()
    }
    
    func advertiserStop(){
        advertiser.stop()
    }
    
    //--------------------------MCSession Delegate Functions
    // Remote peer changed state.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        print("didChangeState")
    }
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        print("didReceiveData")
        let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String : Any]
        if let resp = (dictionary as! NSDictionary)["id"] as? String {
            print("yuh")
            if resp == UserDefaults.standard.object(forKey: "id") as? String {
                print("yuh1")
                if let respMsg = (dictionary as! NSDictionary)["msg"] as? String {
                    print("yuh2")
                    LocationViewController.LocationControllerInstance.showMsg(msg : respMsg)
                }
            } else {
                if(InternetManager.internetManager.isInternetAvailable()){
                    print("yuh3")
                    print(dictionary)
                    LocationViewController.LocationControllerInstance.safetyPost(params: dictionary!)
                } else {
                    print("yuh4")
                    PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: dictionary))
                }
            }
        }
    }
    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        print("didReceivestream")
    }
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        print("didStartReceivingResourceWithName " + resourceName)
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?){
        print("didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Swift.Void){
        print(certificateHandler(true))
    }
    
}

