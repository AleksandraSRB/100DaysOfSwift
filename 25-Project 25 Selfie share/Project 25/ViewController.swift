//
//  ViewController.swift
//  Project 25
//
//  Created by Aleksandra Sobot on 12.3.24..
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var images = [UIImage]()
    private var cellTag = 1000
    var serviceType = "hws-project25"
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Selfie Share"
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let message = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(sendMessageAlert))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        let online = UIBarButtonItem(title: "Online", style: .plain, target: self, action: #selector(viewOnlineList))
        
        navigationItem.rightBarButtonItems = [camera, message]
        navigationItem.leftBarButtonItems = [add, online]
        
        mcSession = MCSession(peer: peerID , securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(cellTag) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }
    
    
    @objc func showConnectionPrompt() {
        let alertController = UIAlertController(title: "Coonect to others", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        alertController.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    // Challange 2.
    @objc func sendMessageAlert() {
        let ac = UIAlertController(title: "Send text message", message: "", preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].placeholder = "Type your message"
        ac.addAction(UIAlertAction(title: "SEND", style: .default) { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            if text != ""{
                self?.sendMessage(text: text)
            }
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    // Challange 2.
    @objc func sendMessage(text: String) {
       let data = Data(text.utf8)
        guard let mcSession = mcSession else { return }
        
        if mcSession.connectedPeers.count > 0 {
                do {
                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let alertController = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alertController, animated: true)
                }
            }
        }
    // Challange 3. - Shows list of online peers
    @objc func viewOnlineList() {
        guard let mcSession = mcSession else { return }
        var peerName = ""
        
        if mcSession.connectedPeers.count > 0 {
            for peer in mcSession.connectedPeers {
                peerName = peer.displayName
            }
            
            let ac = UIAlertController(title: "Connected devices:", message: "\(peerName) \n", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Connected devices:", message: "No connected devices", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    // method that had to be adopted when conformng to protocol MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
        
        let ac = UIAlertController(title: "Connection Request", message: "User: \(peerID) is requesting to join the network.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Allow", style: .default) {[weak self] action in
            invitationHandler(true, self?.mcSession)
        })
        ac.addAction(UIAlertAction(title: "Deny", style: .cancel) {[weak self] action in
            invitationHandler(false, self?.mcSession)
        })
        present(ac, animated: true)
        
    }
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            // Challange 1. - Sending an alert when peer is disconnected
            let alertController = UIAlertController(title: "Disconnected", message: "\(peerID.displayName) has disconnected", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alertController, animated: true)
            //            print("Not Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .connected:
            print("Connected: \(peerID.displayName)")
        @unknown default:
            print("Unkown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data)  {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
                // Challange 2. sending a text message to connected peers
            } else {
             let textMessage = String(decoding: data, as: UTF8.self)
                let ac = UIAlertController(title: "Message from: \(peerID.displayName)", message: "\(textMessage)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        }
    }
}
  extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
          
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          
          guard let image = info[.editedImage] as? UIImage else { return }
          dismiss(animated: true)
          
          images.insert(image, at: 0)
          collectionView.reloadData()
          
          guard let mcSession = mcSession else { return }
          
          if mcSession.connectedPeers.count > 0 {
              if let imageData = image.pngData() {
                  do {
                      try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                  } catch {
                      let alertController = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                      alertController.addAction(UIAlertAction(title: "OK", style: .default))
                      present(alertController, animated: true)
                  }
              }
          }
      }
      
      @objc func importPicture(){
          let picker = UIImagePickerController()
          picker.allowsEditing = true
          picker.delegate = self
          present(picker, animated: true)
      }
  }


