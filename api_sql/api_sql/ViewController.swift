import UIKit
import SQLite3

class ViewController: UIViewController {

    
    @IBOutlet weak var nameT: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var locaton: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    @IBAction func cargar(_ sender: Any) {
        printUserDataFromDatabase()
        guard let name = nameT.text, !name.isEmpty else {
                print("Name is empty")
                return
            }
            
            guard let db = openDatabase() else {
                print("Unable to open database")
                return
            }
            
            let query = "SELECT * FROM users WHERE name = ?;"
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error preparing query: \(errmsg)")
                sqlite3_close(db)
                return
            }
            
            if sqlite3_bind_text(statement, 1, name, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error binding name: \(errmsg)")
                sqlite3_finalize(statement)
                sqlite3_close(db)
                return
            }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                // Usuario encontrado
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let email = String(cString: sqlite3_column_text(statement, 2))
                let location = String(cString: sqlite3_column_text(statement, 3))
                let phone = String(cString: sqlite3_column_text(statement, 4))
                
                // Actualizar los campos de texto con los datos cargados
                DispatchQueue.main.async {
                    self.nameT.text = name
                    self.email.text = email
                    self.locaton.text = location
                    self.phone.text = phone
                }
                
                print("User loaded successfully.")
            } else {
                // Usuario no encontrado
                print("User not found.")
            }
            
            sqlite3_finalize(statement)
            sqlite3_close(db)
    }
    @IBAction func save(_ sender: Any) {
        guard let name = nameT.text, !name.isEmpty,
                      let email = email.text, !email.isEmpty,
                      let location = locaton.text, !location.isEmpty,
                      let phone = phone.text, !phone.isEmpty else {
                    print("Some fields are empty")
                    return
                }
                
                guard let db = openDatabase() else {
                    print("Unable to open database")
                    return
                }
                
                let insertQuery = "INSERT INTO users (name, email, location, phone) VALUES (?, ?, ?, ?);"
                
                var statement: OpaquePointer?
                
                if sqlite3_prepare(db, insertQuery, -1, &statement, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error preparing insert: \(errmsg)")
                    sqlite3_close(db)
                    return
                }
                
                if sqlite3_bind_text(statement, 1, name, -1, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error binding name: \(errmsg)")
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return
                }
                
                if sqlite3_bind_text(statement, 2, email, -1, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error binding email: \(errmsg)")
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return
                }
                
                if sqlite3_bind_text(statement, 3, location, -1, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error binding location: \(errmsg)")
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return
                }
                
                if sqlite3_bind_text(statement, 4, phone, -1, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error binding phone: \(errmsg)")
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return
                }
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Failure inserting user: \(errmsg)")
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return
                }
                
                print("User inserted successfully.")
                sqlite3_finalize(statement)
                sqlite3_close(db)
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        self.email.text = ""
        self.locaton.text = ""
        self.phone.text = ""
    }
    
    @IBAction func generar(_ sender: Any) {
        fetchRandomUser { result in
                    switch result {
                    case .success(let user):
                        DispatchQueue.main.async {
                            self.nameT.text = "\(user.name.first) \(user.name.last)"
                            self.email.text = user.email
                            self.locaton.text = "\(user.location.city), \(user.location.country)"
                            self.phone.text = user.phone
                        }
                    case .failure(let error):
                        print("Error fetching random user: \(error)")
                    }
                }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       createTable()
        // Do any additional setup after loading the view.
        
    }
    
    struct RandomUser: Codable {
        struct Name: Codable {
            let title: String
            let first: String
            let last: String
        }
        
        struct Location: Codable {
            let city: String
            let country: String
        }
        
        let name: Name
        let email: String
        let location: Location
        let phone: String
    }
    
    func fetchRandomUser(completion: @escaping (Result<RandomUser, Error>) -> Void) {
        let url = URL(string: "https://randomuser.me/api/")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(RandomUserResponse.self, from: data)
                if let user = decodedData.results.first {
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user data found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    struct RandomUserResponse: Codable {
        let results: [RandomUser]
    }
    
    func openDatabase() -> OpaquePointer? {
            var db: OpaquePointer?
            
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("database.sqlite")
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error opening database")
                return nil
            }
            print("Successfully opened connection to database.")
            return db
        }
    
    func createTable() {
        guard let db = openDatabase() else {
            print("Unable to open database")
            return
        }
        
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            location TEXT,
            phone TEXT
        );
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing create table: \(errmsg)")
            sqlite3_close(db)
            return
        }
        
        if sqlite3_step(createTableStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Failure creating table: \(errmsg)")
            sqlite3_finalize(createTableStatement)
            sqlite3_close(db)
            return
        }
        
        print("Table created successfully")
        sqlite3_finalize(createTableStatement)
        sqlite3_close(db)
    }

    func printUserDataFromDatabase() {
        guard let db = openDatabase() else {
            print("Unable to open database")
            return
        }
        
        let query = "SELECT * FROM users;"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing query: \(errmsg)")
            sqlite3_close(db)
            return
        }
        
        print("Printing user data from database:")
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let email = String(cString: sqlite3_column_text(statement, 2))
            let location = String(cString: sqlite3_column_text(statement, 3))
            let phone = String(cString: sqlite3_column_text(statement, 4))
            
            print("ID: \(id), Name: \(name), Email: \(email), Location: \(location), Phone: \(phone)")
            
            if self.nameT.text == name {
                self.nameT.text = name
                self.email.text = email
                self.locaton.text = location
                self.phone.text = phone
            }
            
            
        }
        
        sqlite3_finalize(statement)
        sqlite3_close(db)
    }

}
