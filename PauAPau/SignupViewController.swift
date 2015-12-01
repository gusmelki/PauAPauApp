//
//  SignupViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 05/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var celular: UITextField!
   
    @IBOutlet weak var inscrevaseBotao: UIButton!
    
    
    @IBOutlet weak var imagemNome: UIImageView!
    @IBOutlet weak var imagemEmail: UIImageView!
    @IBOutlet weak var imagemCelular: UIImageView!
    @IBOutlet weak var imagemSenha: UIImageView!
    
    var loading: MBProgressHUD?

    @IBAction func inscrevasePressed(sender: AnyObject) {
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Cadastrando"
        
        let user = PFUser()

        user["name"] = nome.text
        user.password = senha.text
        user.username = email.text
        user.email = email.text
        user["phone"] = celular.text
        
        
        user.signUpInBackgroundWithBlock {
        (succeeded, error) -> Void in
        if error == nil {
            
            // desativando o ActivitiIndicator
            if let loading = self.loading{
                loading.hide(true)
            }
            
            //criar a proxima tela
            let proximaTela = self.storyboard?.instantiateViewControllerWithIdentifier("ControladoraViewController") as? ControladoraViewController
            
            //Realizar a transicao
            self.presentViewController(proximaTela!, animated: true, completion: nil)
            
            print("Cadastrado")
        
        } else {
          
            // desativando o ActivitiIndicator
            if let loading = self.loading{
                loading.hide(true)
            }

            
            let errorString = error!.localizedDescription
            
            let errorCode = error!.code
            
            switch errorCode{
            case 100:
                print(errorString)
                self.alertaSimples("Conexão", message: "Sem acesso a Internet")
            case 125:
                print(errorString)
                self.alertaSimples("Email Inválido", message: "exemplo@exemplo.com")
                self.email.text = ""
            case 202:
                print(errorString)
                self.alertaSimples("Usuário já cadastrado", message: "Faça seu login")
                self.email.text = ""
            default:
                break
            }
            
            
            }
        }
    }
    
    
    // Monitora o TextFild para quando estiverem preenchidos Habilitarem o Botao de Inscrever-se
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if nome.text != "" && email.text != "" && senha.text != "" && celular.text != ""{
            
            self.inscrevaseBotao.enabled = true
            self.inscrevaseBotao.alpha = 1.0
            
        }else{
            
            self.inscrevaseBotao.enabled = false
            self.inscrevaseBotao.alpha = 0.3
        }
        
        return true
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nome.becomeFirstResponder()
        
        //esconde o teclado
        nome.delegate = self
        email.delegate = self
        senha.delegate = self
        celular.delegate = self
        
        inscrevaseBotao.enabled = false
        
        //Ajusta a imagem dos txtFilds
        self.imagemEmail.layer.cornerRadius = 5.0
        self.imagemEmail.layer.borderWidth = 1
        self.imagemEmail.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.imagemNome.layer.cornerRadius = 5.0
        self.imagemNome.layer.borderWidth = 1
        self.imagemNome.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.imagemSenha.layer.cornerRadius = 5.0
        self.imagemSenha.layer.borderWidth = 1
        self.imagemSenha.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.imagemCelular.layer.cornerRadius = 5.0
        self.imagemCelular.layer.borderWidth = 1
        self.imagemCelular.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Barra visivel
        self.navigationController?.navigationBarHidden = false
        //Titulo da barra
        self.title = "Inscreva-se"
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

