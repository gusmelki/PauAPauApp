//
//  MercadoViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 09/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit


class MercadoViewController: UIViewController {

    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var descricao: UITextView!
    
    var objetos = [PFObject]()
    
    var contadorObjeto = 0
    
    var loading: MBProgressHUD?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configura a textView
        self.descricao.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.descricao.layer.borderWidth = 1.0
        self.descricao.layer.cornerRadius = 8
        self.descricao.backgroundColor = UIColor.whiteColor()
       
        //Configura a labeltitulo
        self.titulo.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.titulo.layer.borderWidth = 1.0
        self.titulo.layer.cornerRadius = 8
        self.titulo.backgroundColor = UIColor.whiteColor()
        
        //Configura ImageView
        self.imagem.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.imagem.layer.borderWidth = 1.0
        self.imagem.layer.cornerRadius = 8
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Carregando..."
        
        carregaItens()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func botaoGostoPressed(sender: AnyObject) {
       
        if objetos.count > contadorObjeto {
        
        let idObjeto = objetos[contadorObjeto]
        let usuarioAtual = PFUser.currentUser()!.username
        
        idObjeto.addUniqueObject(usuarioAtual!, forKey: "aceitos")
        idObjeto.saveInBackgroundWithBlock(nil)
            
        contadorObjeto++
        print(contadorObjeto)
        adicionaIntesNaTela()
    }
        
    }
    
    @IBAction func botaoNaoGostoPressed(sender: AnyObject) {
        
        if objetos.count > contadorObjeto {
            
            let idObjeto = objetos[contadorObjeto]
            let usuarioAtual = PFUser.currentUser()!.username
            
            idObjeto.addUniqueObject(usuarioAtual!, forKey: "naoAceitos")
            idObjeto.saveInBackgroundWithBlock(nil)
            
            contadorObjeto++
            print(contadorObjeto)
            adicionaIntesNaTela()
        }
        
    }
    
    
    func carregaItens(){
        
        // Confere se exite usuario logado
        if PFUser.currentUser() != nil {
        
        let query = PFQuery(className: "Itens")
        query.whereKey("usuario", notEqualTo: PFUser.currentUser()!.username!)
        query.whereKey("aceitos", notEqualTo: PFUser.currentUser()!.username!)
        query.whereKey("naoAceitos", notEqualTo: PFUser.currentUser()!.username!)
        query.limit = 10
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for _ in objects {
                        self.objetos = objects
                        //println(object.objectId)
                    }
                    
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }

                    
                    if self.objetos.isEmpty{
                        // Para todo a vez que nao houver objetos disponiveis ele execitar a query novamente
                        self.imagem.image = UIImage(named: "placeholder")
                        _ = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("carregaItens"), userInfo: nil, repeats: false)
                    }
                    else{
                        self.adicionaIntesNaTela()
                    }
                }
            } else {
                // Log details of the failure
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    }
    
    
    func adicionaIntesNaTela(){
        
        if objetos.count > contadorObjeto && objetos.count != 0 {
        
        self.titulo.text = objetos[contadorObjeto]["titulo"] as! NSString as String
        self.descricao.text = objetos[contadorObjeto]["Descricao"] as! NSString as String
        let itemImageFile = objetos[contadorObjeto]["imagem"] as! PFFile
        itemImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                self.imagem.image = UIImage(data:imageData!)
                }
            }
            
        }else{
            
            print("acabou os objetos")
            self.imagem.image = UIImage(named: "placeholder")
            self.titulo.text = ""
            self.descricao.text = ""
            objetos.removeAll()
            contadorObjeto = 0
            carregaItens()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
