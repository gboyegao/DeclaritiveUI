//
//  Types.swift
//  DeclaritiveUI
//
//  Created by Adegboyega Olusunmade on 03/03/2019.
//  Copyright © 2019 Adegboyega Olusunmade. All rights reserved.
//

import Foundation
import AVKit
import SafariServices


enum ActionCodingKeys:CodingKey{
    case title
    case actionType
    case action
}


struct Application:Decodable{
    let screens:[Screen]
}

struct Screen:Decodable {
    let id:String
    let title:String
    let type:String
    let rows:[Row]
    let rightButton:Button?
}

protocol HasAction {
   
}
extension HasAction{
    
     func decodeAction(from container:KeyedDecodingContainer<ActionCodingKeys>) throws -> Action?{
        if let actionType = try container.decodeIfPresent(String.self, forKey: .actionType){
            switch actionType{
            case "alert":
                return try container.decode(AlertAction.self, forKey: .action)
            case "showWebsite":
                return try container.decode(ShowWebsiteAction.self,forKey:.action)
            case "showScreen":
                return try container.decode(ShowScreenAction.self,forKey:.action)
            case "shareAction":
                return try container.decode(ShareAction.self,forKey:.action)
            case "playMovie":
                return try container.decode(PlayMovie.self,forKey:.action)
            default:
                fatalError("Unkwon action type: \(actionType)")
            }
        }
        else{
           return nil
        }
        
    }
    
}



struct Row:Decodable,HasAction{
    
    let title:String
    var action:Action? = nil
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionCodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        action = try decodeAction(from: container)
        
    }
}

struct Button:Decodable,HasAction{
    
    let title:String
    var action:Action? = nil
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionCodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        action = try decodeAction(from: container)
        
    }
}

protocol Action:Decodable {
    var presentNewScreen:Bool {get}
    
}

struct AlertAction:Action {
    let title:String
    let message:String
    
    var presentNewScreen: Bool{
        return false
    }
}

struct ShowWebsiteAction:Action{
    let url:String
    var presentNewScreen: Bool{
        return true
    }
}

struct ShowScreenAction:Action {
    let id:String
    var presentNewScreen: Bool{
        return true
    }

}


struct ShareAction:Action {
    let text:String?
    let url:URL?
    
    var presentNewScreen: Bool{
        return false
    }
    
}

struct PlayMovie:Action{
    let url:URL
    var presentNewScreen: Bool{
        return true
    }
}



class NavigationManager{
    private var screens = [String:Screen]()
    
    func fetch(completionHandler:(Screen) -> Void){
        let url = URL(string: "http://localhost:8090/index.json")!
        let data = try! Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        
        let app = try! decoder.decode(Application.self, from: data)
        
        for screen in app.screens{
            screens[screen.id] = screen
        }
        
        completionHandler(app.screens[0])
    }
    
    func execute(_ action:Action?,from viewcontroller:UIViewController){
        guard let action = action else{return}
        
        if let action = action as? AlertAction{
            let ac = UIAlertController(title: action.title, message: action.message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            viewcontroller.present(ac, animated: true)
        }
        else if let action = action as? ShowWebsiteAction{
            guard let url = URL(string: action.url) else {return}
            
            let safariVC  = SFSafariViewController(url: url)
            viewcontroller.present(safariVC, animated: true)
            
        }
        else if let action = action as? ShowScreenAction{
            guard let screen = screens[action.id] else {
                fatalError("Attempting to load invalid screen")
            }
            
            let vc = TableScreen(screen: screen)
            vc.navigationManager = self
            viewcontroller.navigationController?.pushViewController(vc, animated: true)
        }
        else if let action = action as? PlayMovie{
            let player = AVPlayer(url: action.url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            player.play()
            
            viewcontroller.present(playerViewController,animated: true)
            
        }
        else if let action = action as? ShareAction{
            var items = [Any]()
            
            if let text = action.text { items.append(text)}
            if let url = action.url { items.append(url)}
            
            if items.isEmpty == false{
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                viewcontroller.present(ac, animated: true)
            }
        }
    
    }
    
}
