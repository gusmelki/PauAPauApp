//
//  LarViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 09/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit
import MobileCoreServices


class LarViewController: UIViewController {
    
    
    
    @IBOutlet weak var nomeUsuario: UILabel!
    @IBOutlet weak var imagemPerfil: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var objetos = [PFObject]()
    
    var loading: MBProgressHUD?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturandoAsInformacoesDoUsuario()
        carregandoItensDoUsuario()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func botaoSairPressed(sender: AnyObject) {
        
        PFUser.logOut()
        
        //criar a proxima tela
        let proximaTela = self.storyboard?.instantiateViewControllerWithIdentifier("NavegationController") as? NavegationController
        
        //Realizar a transicao
        self.presentViewController(proximaTela!, animated: true, completion: nil)
        print("LogOut")
        
    }
    
    
    func capturandoAsInformacoesDoUsuario(){
        
        let query = PFUser.query()
        query!.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        query!.findObjectsInBackgroundWithBlock { (infos:[PFObject]?, erro: NSError?) -> Void in
            
            if erro == nil {
                for info in infos!{
                    // Download do Nome
                    let nome = info.objectForKey("name") as! String
                    self.nomeUsuario.text = nome
                    //Download da Imagem
                    let fotoPerfilFile = info.objectForKey("fotoPerfil") as! PFFile?
                    if let fotoPerfilFileVerificada = fotoPerfilFile{
                        fotoPerfilFileVerificada.getDataInBackgroundWithBlock({ (fotoPerfilData: NSData?, erro : NSError?) -> Void in
                            if erro == nil{
                                let imagemPerfil = UIImage(data: fotoPerfilData!)
                                self.imagemPerfil.image = imagemPerfil
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func carregandoItensDoUsuario(){
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Carregando..."
        
        let query = PFQuery(className: "Itens")
        query.whereKey("usuario", equalTo: PFUser.currentUser()!.username!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.objetos = objects
                    
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }
                    
                    // Atualiza as celulas
                    self.collectionView.reloadData()
                    
                }
            } else {
                // Log details of the failure
                
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }

                self.alertaSimples("Falha na conexão", message: "Tente mais tarde")
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func editarFotoUsuarioPressed(sender: UIButton) {
        
        mostrarPopOverCamera(sender)
    }
    
    
    func mostrarPopOverCamera(sender:UIButton){
        
        let alerta = UIAlertController(title: "Foto", message: "Alterar foto do perfil", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //ajustar a apresentacao do popOver caso o divace seja um ipad
        alerta.popoverPresentationController?.sourceView = self.view
        alerta.popoverPresentationController?.sourceRect = sender.frame
        
        
        let actionCamera = UIAlertAction(title: "Tirar Foto", style: .Default) { (action) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                
                let imagem = UIImagePickerController()
                imagem.delegate = self
                imagem.sourceType = UIImagePickerControllerSourceType.Camera
                imagem.mediaTypes = [kUTTypeImage as String]
                imagem.allowsEditing = true
                
                self.presentViewController(imagem, animated: true, completion: nil)
            }
            
        }
        
        let actionBiblioteca = UIAlertAction(title: "Escolher na biblioteca", style: .Default) { (action) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                
                let imagem = UIImagePickerController()
                imagem.delegate = self
                imagem.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagem.mediaTypes = [kUTTypeImage as String]
                imagem.allowsEditing = true
                
                self.presentViewController(imagem, animated: true, completion: nil)
            }
            
            
        }
        
        let actionCancelar = UIAlertAction(title: "Cancelar", style: .Destructive, handler: nil)
        
        //Apresentando os actions ao alerta
        alerta.addAction(actionCamera)
        alerta.addAction(actionBiblioteca)
        alerta.addAction(actionCancelar)
        
        //Apresentando o alerta Modal
        self.presentViewController(alerta, animated: true, completion: nil)
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

extension LarViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // tira a view da camera e volta para o Lar
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Atualizando foto do perfil"
        
        //Salvando a Imagem De Perfil no Parse
        let imagemPerfilData = UIImagePNGRepresentation(image)
        let imagemPerfilFile = PFFile(data: imagemPerfilData!)
        
        PFUser.currentUser()!["fotoPerfil"] = imagemPerfilFile
        PFUser.currentUser()!.saveInBackgroundWithBlock { (sucesso, erro) -> Void in
            
            if erro == nil {
                print("Imagem salva com sucesso")
                self.imagemPerfil.image = image
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                
            }
                
            else{
                
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                self.alertaSimples("Foto não atualizada", message: "Não foi possivel atualizar a foto do seu perfil")
            }
            
            
        }
        
    }
}
    

// Itens do Lar
extension LarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // Numero de itens posiveis
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objetos.count
    }
    
    // Configuracao da celula - montar um array
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : MeuItemCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MeuItemCollectionViewCell
        
        cell.titulo.text = objetos[indexPath.row]["titulo"] as! NSString as String
        cell.descricao.text = objetos[indexPath.row]["Descricao"] as! NSString as String
        
        let itemImageFile = objetos[indexPath.row]["imagem"] as! PFFile
        itemImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                cell.imagem.image = UIImage(data:imageData!)
            }
        }
        
        return cell
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let alerta = UIAlertController(title: "Apagar", message: "Deseja apagar sua publicação?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //ajustar a apresentacao do popOver caso o divace seja um ipad
        alerta.popoverPresentationController?.sourceView = self.view
        
        let actionApagar = UIAlertAction(title: "Apagar", style: .Destructive) { (action) -> Void in
            
            //ativando o ActivitiIndicator
            self.loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.loading?.mode = MBProgressHUDMode.Indeterminate
            self.loading?.dimBackground = true
            self.loading?.labelText = "Deletando..."
            
            _ = collectionView.cellForItemAtIndexPath(indexPath)
            let objetoSelecionado = self.objetos[indexPath.row]
            print(objetoSelecionado)
            objetoSelecionado.deleteInBackgroundWithBlock({ (sucesso, error) -> Void in
                if error == nil{
                    print("imagem Deletada")
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }
                    self.objetos.removeAtIndex(indexPath.row)
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                }
                else{
                    // desativando o ActivitiIndicator
                    if let loading = self.loading{
                        loading.hide(true)
                    }
                    self.alertaSimples("Conexão", message: "Não foi possivel deleter seu objeto")
                }
            })
        }
        
        let actionCancelar = UIAlertAction(title: "Cancelar", style: .Default, handler: nil)
        
        //Apresentando os actions ao alerta
        alerta.addAction(actionApagar)
        alerta.addAction(actionCancelar)
        
        //Apresentando o alerta Modal
        self.presentViewController(alerta, animated: true, completion: nil)
        
    }
}

extension LarViewController: ItemViewControllerDelegate{
    
    func newItemSavedOnParse(newItem: PFObject) {
        self.objetos.insert(newItem, atIndex: 0)
        let indexPathToInsert = NSIndexPath(forItem: 0, inSection: 0)
        self.collectionView.insertItemsAtIndexPaths([indexPathToInsert])
    }
}


