//
//  MySettingViewController.swift
//  Books
//
//  Created by 김인로 on 2017. 5. 31..
//  Copyright © 2017년 김인로. All rights reserved.
//

import Eureka


class BooksLogoViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MySettingViewController: FormViewController {
    
    
    let settings = Util.getSettings() as NSMutableDictionary
    let path = Util.homeDir+"/Settings.plist"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form
             +++ Section() {
                var header = HeaderFooterView<BooksLogoViewNib>(.nibFile(name: "BooksSectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 1;
                   /* UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })*/
                    //view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                   // UIView.animate(withDuration: 1.0, animations: { [weak view] in
                    //    view?.layer.transform = CATransform3DIdentity
                   // })
                    
                }
                $0.header = header
            }
            
          
            +++ Section("Epub Reader")
            
            <<< SwitchRow("switchRowTag"){
                
                $0.title = "TTS (Text to Speech)"
                $0.value = settings.object(forKey: "tts") as? Bool
                }
                .onChange { (switchRow) in
                    print("TTS: \(switchRow.value!)")
                    
                    self.settings.setValue(switchRow.value, forKey: "tts")
                    self.settings.write(toFile: self.path, atomically: true)
            }
            
       /*     <<< SwitchRow("switchRowTag2"){
                
                $0.hidden = Condition.function(["switchRowTag"], { form in
                    return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Background Audio"
                $0.value = settings.object(forKey: "back_audio") as? Bool
                }
                .onChange { (switchRow) in
                    print("Background Audio: \(switchRow.value!)")
                    self.settings.setValue(switchRow.value, forKey: "back_audio")
                    self.settings.write(toFile: self.path, atomically: true)
            }
        */
            
            <<< PushRow<String>() {
                $0.title = "Menu Color"
                $0.options = ["Black", "Red", "Blue", "Green", "Purple", "Brown", "DarkGray"]
                $0.value = settings.object(forKey: "menu_color") as? String
               // $0.selectorTitle = "Choose a Color."
                }
                .onChange {(pushRow) in
                    self.settings.setValue(pushRow.value, forKey: "menu_color")
                    self.settings.write(toFile: self.path, atomically: true)
            }
           
            +++ Section("General")
        
            <<< ButtonRow("About") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "showAppInfo", onDismiss: nil)
            }
        
    }
}


