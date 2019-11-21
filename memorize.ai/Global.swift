import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

let auth = Auth.auth()
let firestore = Firestore.firestore()
let storage = Storage.storage().reference()

let SCREEN_SIZE = UIScreen.main.bounds

func popUpWithAnimation(body: () -> Void) {
	withAnimation(.easeIn(duration: 0.15), body)
}
