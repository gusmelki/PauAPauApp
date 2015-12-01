//
//  DetalhesContatoViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 13/04/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit


class DetalhesContatoViewController: UIViewController {

    @IBOutlet weak var tabela: UITableView!
    
    var emailUsuario = String()
    
    @IBOutlet weak var fotoUsuario: UIImageView!
    @IBOutlet weak var nomeUsuario: UILabel!
    @IBOutlet weak var telefoneUsuario: UILabel!
    
    var usuariosAceitos = [String]()
    var objetosMatchUsuarioCorrente = [PFObject]()
    
    var loading: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        carregandoUsuariosMatch()
        carregandoItensUsuarioCorrente()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func botaoVoltarPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //=========== Os Usuarios Do Match =============//
    func carregandoUsuariosMatch (){

        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Buscando dados do usuário..."
        
        
        let query = PFUser.query()
        query!.whereKey("email", equalTo: emailUsuario)
        query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects as! [PFUser]! {
                    for object in objects{
                        self.nomeUsuario.text = object["name"] as? String
                        self.telefoneUsuario.text = object["phone"] as? String
                        
                        let fotoPerfilFile = object.objectForKey("fotoPerfil") as! PFFile?
                        if let fotoPerfilFileVerificada = fotoPerfilFile{
                            fotoPerfilFileVerificada.getDataInBackgroundWithBlock({ (fotoPerfilData, erro) -> Void in
                                if erro == nil{
                                    let imagemPerfil = UIImage(data: fotoPerfilData!)
                                    self.fotoUsuario.image = imagemPerfil
                                }// end if
                            })// end clouser
                        }// end for
                    }
                    
                }else{
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }
                    
                    self.alertaSimples("Conexão", message: "Conexão instável, tente mais tarde")
                    print("erro")
            }
        }
    }
}
    
    func carregandoItensUsuarioCorrente(){
        let queryMatch = PFQuery(className: "Itens")
        queryMatch.whereKey("usuario", equalTo: PFUser.currentUser()!.username!)
        queryMatch.whereKey("aceitos", equalTo: emailUsuario)
        queryMatch.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }

                
                if let objects = objects as [PFObject]! {
                    self.objetosMatchUsuarioCorrente = objects
                }
            }else{
                
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }

                self.alertaSimples("Conexão", message: "Conexão instável, tente mais tarde")
                print("erro")
            }
            self.tabela.reloadData()
            print(self.objetosMatchUsuarioCorrente.count)
            print(self.objetosMatchUsuarioCorrente)
        }
    }
    
    func alertaSimples(title:String, message:String){
        // Alerta
        let alerta = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alerta.addAction(actionOk)
        self.presentViewController(alerta, animated: true, completion: nil)
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

extension DetalhesContatoViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objetosMatchUsuarioCorrente.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! DetalhesContatoTableViewCell
        
        cell.titulo.text = objetosMatchUsuarioCorrente[indexPath.row]["titulo"] as? String
        
        let itemImageFile = objetosMatchUsuarioCorrente[indexPath.row]["imagem"] as! PFFile
        itemImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                cell.imagem.image = UIImage(data:imageData!)
            }
        }

        return cell
    }

}


