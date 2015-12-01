//
//  LoginViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 05/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var entrarBotao: UIButton!
    @IBOutlet weak var imagemEmail: UIImageView!
    @IBOutlet weak var imagemSenha: UIImageView!
    
    var loading: MBProgressHUD?
    
    @IBAction func entrarPressed(sender: AnyObject) {
        
        //ativando o ActivitiIndicator
        loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading?.mode = MBProgressHUDMode.Indeterminate
        loading?.dimBackground = true
        loading?.labelText = "Entrando"

        
        PFUser.logInWithUsernameInBackground(email.text!, password:senha.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                // desativando o ActivitiIndicator
                if let loading = self.loading{
                    loading.hide(true)
                }
                
                //criar a proxima tela
                let proximaTela = self.storyboard?.instantiateViewControllerWithIdentifier("ControladoraViewController") as? ControladoraViewController
                
                //Realizar a transicao
                self.presentViewController(proximaTela!, animated: true, completion: nil)
                print("Logado")
                
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
                case 101:
                    print(errorString)
                    self.alertaSimples("Email ou Senha inválidos", message: "Tente novamente")
                default:
                    break
                }
                
                self.email.text = ""
                self.senha.text = ""
                
            }
        }
        
    }
    
    
    // Monitora o TextFild para quando estiverem preenchidos Habilitarem o Botao de Inscrever-se
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if  email.text != "" && senha.text != "" {
            
            self.entrarBotao.enabled = true
            self.entrarBotao.alpha = 1.0
            
        }else{
            
            self.entrarBotao.enabled = false
            self.entrarBotao.alpha = 0.3
        }
        
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.becomeFirstResponder()
        
        //Esconde o Teclado
        email.delegate = self
        senha.delegate = self
        
        
        entrarBotao.enabled = false
        
        //Ajusta a imagem dos txtFilds
        self.imagemEmail.layer.cornerRadius = 5.0
        self.imagemEmail.layer.borderWidth = 1
        self.imagemEmail.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        
        self.imagemSenha.layer.cornerRadius = 5.0
        self.imagemSenha.layer.borderWidth = 1
        self.imagemSenha.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        //Titulo da barra
        self.title = "Entrar"
    
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
