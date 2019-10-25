import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

let auth = Auth.auth()
let firestore = Firestore.firestore()
let storage = Storage.storage().reference()

let SCREEN_SIZE = UIScreen.main.bounds
