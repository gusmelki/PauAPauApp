//
//  ContatosViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 09/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit


class ContatosViewController: UIViewController {
    
    @IBOutlet weak var tabela: UITableView!
    
    var usuariosQueAceitram = [String]()
    var objetosMacthUsuarios = [PFObject]()
    
    var loading: MBProgressHUD?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         carregandoObjetosAceitosUsuario()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //============== Itens Outros Usuarios ===========//
    
    func carregandoObjetosAceitosUsuario(){
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Combinando itens..."
        
        let queryAceitos = PFQuery(className: "Itens")
        queryAceitos.whereKey("usuario", equalTo: (PFUser.currentUser()!.username!))
        queryAceitos.selectKeys(["aceitos"])
        queryAceitos.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects as [PFObject]! {
                    for object in objects{
                        if let usuarios = object["aceitos"] as? [String]{
                            for usuario in usuarios{
                                self.usuariosQueAceitram.append(usuario)
                            }
                        }
                    }
                }
            }else{
                print("erro")
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                self.alertaSimples("Conexão", message: "Conexão instável, tente mais tarde")
            }
            self.itensMachUsuarios()
        }
    }

    func itensMachUsuarios(){
        let queryMatch = PFQuery(className: "Itens")
        queryMatch.whereKey("usuario", containedIn: usuariosQueAceitram)
        queryMatch.whereKey("aceitos", equalTo: (PFUser.currentUser()!.username!))
        queryMatch.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects as [PFObject]? {
                    self.objetosMacthUsuarios = objects
                    
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }
                    
                }
            }else{
                print("erro")
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                self.alertaSimples("Conexão", message: "Conexão instável, tente mais tarde")
            }
            self.tabela.reloadData()
            print(self.objetosMacthUsuarios.count)
            print(self.objetosMacthUsuarios)
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

extension ContatosViewController : UITableViewDataSource, UITableViewDelegate{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objetosMacthUsuarios.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ContatosTableViewCell
    
        cell.titulo.text = objetosMacthUsuarios[indexPath.row]["titulo"] as! NSString as String
        let itemImageFile = objetosMacthUsuarios[indexPath.row]["imagem"] as! PFFile
        itemImageFile.getDataInBackgroundWithBlock {
            (imageData, error) -> Void in
            if error == nil {
                cell.imagem.image = UIImage(data:imageData!)
            }
        }
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //criar a proxima tela
        let proximaTela = self.storyboard?.instantiateViewControllerWithIdentifier("DetalhesContatoViewController") as? DetalhesContatoViewController
        
        let email = objetosMacthUsuarios[indexPath.row]["usuario"] as! NSString as String
        
        //Mandando o email para
        proximaTela?.emailUsuario = email
        
        //Realizar a transicao
        self.presentViewController(proximaTela!, animated: true, completion: nil)

    }

}




