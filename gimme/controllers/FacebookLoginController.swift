import Foundation
import UIKit
import FacebookLogin
import FBSDKCoreKit
import Firebase

class FacebookLoginController : UIViewController {
    override func viewDidLoad() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.delegate = self
        loginButton.center = view.center
    
        view.addSubview(loginButton)
    }
}

extension FacebookLoginController : LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("Did complete login via LoginButton with result \(result)")
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
     
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                
                return
            }
            print("Signed in firebase")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did logout via LoginButton")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Logged out firebase")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
