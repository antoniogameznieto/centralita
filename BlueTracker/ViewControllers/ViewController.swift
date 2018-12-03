import UIKit
// Importamos la libreria de bluetooth de apple
import CoreBluetooth

// Aqui hemos metido el UITableDataSource y el Delegate
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate {

    // Definimos la ibOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // Definimos las variables
    var centralManager : CBCentralManager? // El Bluetooth Central Manager
    var names : [String] = [] // El array con los nombres de los dispositivos
    var RSSIs : [NSNumber] = [] // El array con los RSSI de los dispositivos
    var timer : Timer?
    
    // Método viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //Inicializamos el centralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Método propio para cuando pulsemos el botón refrescar
    @IBAction func refreshTapped(_ sender: Any) {
        startScan()
startTimer()
        
    }
    
    // Función que hace que comience un temporizador
    func startTimer(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in
            self.startScan()
        })
    }
    
    // Función que hace que comienze un escaneo de periféricos
    func startScan(){
        names = []
        RSSIs = []
        tableView.reloadData()
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // Codigo para CBCentralManager
    // Si en Central Manager descubre dispositivos los imprimimos por consola
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // No todos los dispositivos tienen nombre, por eso ponemos el if
        if let name = peripheral.name {
            names.append(name) // Añadimos el nombre del periférico encontrado al array
        }
        else{
            names.append(peripheral.identifier.uuidString)
            
        }
        RSSIs.append(RSSI) // Añadimos el RSSI del periférico encontrado al array
        tableView.reloadData() // Recargamos los datos del tableview
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Si el bluetooth está encendido
        if central.state == .poweredOn {
            // Escaneamos por perifericos de cualquier tipo
            startScan()
            startTimer()
            
        }
        // Si está apagado llamamos a un alert controller
        else{
            let alertVC = UIAlertController(title: "Bluetooth isn't working", message: "Make sure your bluetooth is on and ready to rock and roll", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    // Código para el tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count // El máximo de celdas es el número de elementos del array
    }
    // Código de regeneración de celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cuando la celda se regenera, esto pasa
        if let cell = tableView.dequeueReusableCell(withIdentifier: "blueCell", for: indexPath) as? BlueTableViewCell {
            cell.nameLabel.text = names[indexPath.row] // Ponemos el nombre del dispositivo en la etiqueta del nombre
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray // Obligamos a todas las celdas a permitir su selección en gris
            let nivel : Int = Int(truncating: RSSIs[indexPath.row]) // Asignamos el nivel de señal (RSSI) a la variable nivel
            
            if(nivel >= -70){ // Si la señal es estable
                cell.rssiLabel.text = "Conexión estable (\(RSSIs[indexPath.row]))" // Cambiamos el valor de la etiqueta
                cell.rssiLabel.textColor = UIColor(red: 110.0/255.0, green: 170.0/255.0, blue: 60.0/255.0, alpha: 0.7) // Ponemos el texto de la segunda etiqueta en verde
            }

            if(nivel < -70){
                cell.rssiLabel.text = "Señal demasiado débil para conectar (\(RSSIs[indexPath.row]))" // Cambiamos el valor de la etiqueta
                cell.rssiLabel.textColor = UIColor(red: 190.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.7) // Ponemos el texto de la segunda etiqueta en rojo
                cell.selectionStyle = UITableViewCell.SelectionStyle.none // Evitamos que pueda seleccionarse la celda
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selecciona la red \(names[indexPath.row])")
    }
    
}

