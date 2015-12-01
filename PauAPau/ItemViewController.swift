//
//  ItemViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 17/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit
import MobileCoreServices


@objc
protocol ItemViewControllerDelegate{
    func newItemSavedOnParse(newItem: PFObject)
}

class ItemViewController: UIViewController{
    
    weak var delegate: ItemViewControllerDelegate?
    
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var descricao: UITextView!
    
    @IBOutlet weak var botaoPublicar: UIButton!
    
    var loading: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configurando a TextView pra conter PlaceHorlder
        self.descricao.text = "Descrição"
        self.descricao.textColor = UIColor.lightGrayColor()
        
        //Configura a textView
        self.descricao.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.descricao.layer.borderWidth = 1.0
        self.descricao.layer.cornerRadius = 8
        self.descricao.backgroundColor = UIColor.whiteColor()
        
        //Configura ImageView
        self.imagem.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.imagem.layer.borderWidth = 1.0
        self.imagem.layer.cornerRadius = 8
        
        // minimiza o teclado
        titulo.delegate = self
        descricao.delegate = self
        
        self.definirLarDelegate()
    }
    
    func definirLarDelegate(){
        if let tabViewControllers = self.tabBarController?.viewControllers{
            for viewController in tabViewControllers{
                if viewController is LarViewController{
                    self.delegate = viewController as? ItemViewControllerDelegate
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func botaoPublicarPressed(sender: AnyObject) {
        
        //Desativa o Botao para nao apertar 2vezes
        botaoPublicar.enabled = false
        
        if titulo.text != "" {
            
            let item = PFObject(className:"Itens")
            item["usuario"] = PFUser.currentUser()!.username
            item["titulo"] = titulo.text
            item["Descricao"] = descricao.text
            
            
            if let imagem = self.imagem.image {
                let imagemData = UIImagePNGRepresentation(imagem)
                let imagemFile = PFFile(data: (imagemData)!)
                
                item["imagem"] = imagemFile
                
                // monta a barrada de uploading do anuncio
                self.loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.loading?.mode = MBProgressHUDMode.DeterminateHorizontalBar
                self.loading?.dimBackground = true
                self.loading!.labelText = "0"
                
                imagemFile!.saveInBackgroundWithBlock({ (sucesso:Bool, error:NSError?) -> Void in
                    
                    if sucesso {
                        // The object has been saved.
                        print("salvo")
                        
                        //volta a tela para input o
                        self.imagem.image = nil
                        self.titulo.text = ""
                        self.descricao.text = ""
                        
                        // Libera o botao
                        self.botaoPublicar.enabled = true
                        
                        item.saveInBackgroundWithBlock({ (success, error) -> Void in
                            
                            // esconde a barra de recaregar
                            if let loading = self.loading{
                                loading.hide(true)
                            }
                            
                            if success{
                                self.delegate?.newItemSavedOnParse(item)
                                self.alertaSimples("Anúncio", message: "Seu anúncio foi publicado com sucesso =)")
                            }
                            else{
                                self.erroSalvarDados(error!)
                            }
                        })
                        
                    } else {
                        self.erroSalvarDados(error!)
                    }
                    
                    }, progressBlock: { (porcentagem)  -> Void in
                        
                        //mostrando a barra de porcentagem
                        self.loading!.labelText = "Publicando : \(porcentagem) %"
                        self.loading!.progress = Float(porcentagem) / 100
                })
                
            }else{
                // Libera o botao
                self.botaoPublicar.enabled = true
                alertaSimples("Foto", message: "Insira uma Foto")
            }
            
        }else{
            // Libera o botao
            self.botaoPublicar.enabled = true
            alertaSimples("Título", message: "Insira um Título")
        }
    }
    
    func erroSalvarDados(error: NSError){
        print("erro na hora de salvar")
        
        // Libera o botao
        self.botaoPublicar.enabled = true
        
        //volta a tela para input o
        self.imagem.image = nil
        self.titulo.text = ""
        self.descricao.text = ""
        
        // esconde a barra de recaregar
        if let loading = self.loading{
            loading.hide(true)
        }
        
        self.alertaSimples("Anúncio", message: "Não foi possivel publicar seu anuncio =/. Tente mais tarde!")
        
        //exibe a mensage de erro
        let errorString = error.localizedDescription
        
        let errorCode = error.code
        
        switch errorCode{
        case 100:
            print(errorString)
            self.alertaSimples("Conexão", message: "Sem acesso a Internet")
            // Libera o botao
            self.botaoPublicar.enabled = true
        default:
            // Libera o botao
            self.botaoPublicar.enabled = true
            break
        }

    }
    
    
    func desceTela()
    {
        UIView.animateWithDuration(0.25, animations: {self.view.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2) })
    }
    
    func sobeTela()
    {
        UIView.animateWithDuration(0.25, animations: {self.view.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2-120) })
    }
    
    
    @IBAction func botaoCameraPressed(sender: UIButton) {
        
        
        let alerta = UIAlertController(title: "Foto", message: "Adicione uma Foto", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
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

// Teclado
extension ItemViewController : UITextFieldDelegate , UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        sobeTela()
        if descricao.textColor == UIColor.lightGrayColor(){
            descricao.text = nil
            descricao.textColor = UIColor.blackColor()
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if descricao.text.isEmpty{
            descricao.text = "Descrição"
            descricao.textColor = UIColor.lightGrayColor()
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        desceTela()
        
    }
    
}

// Camera Selecionada
extension ItemViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imagem.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


