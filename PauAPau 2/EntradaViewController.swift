//
//  EntradaViewController.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 05/03/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit


class EntradaViewController: UIViewController {
    
    @IBOutlet weak var inscreverBotao: UIButton!
    @IBOutlet weak var entrarBotao: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inscreverBotao.layer.cornerRadius = 5
        entrarBotao.layer.cornerRadius = 5
        
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Confere se já existe um usuario cadastrado e loga ele
    override func viewDidAppear(animated: Bool) {
     
        if PFUser.currentUser() != nil{
            
            //criar a proxima tela
            let proximaTela = self.storyboard?.instantiateViewControllerWithIdentifier("ControladoraViewController") as? ControladoraViewController
            
            //Realizar a transicao
            self.presentViewController(proximaTela!, animated: true, completion: nil)
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
