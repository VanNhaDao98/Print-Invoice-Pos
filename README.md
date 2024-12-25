# Print-Invoice-Pos

Use StreamSocket - TCP

connect printer
        
//        PrintManage.shared.connect(printer: .init(host: "host", port: 0101)) { result in
//            switch result {
//            case .success(let success):
//                break
//            case .failure(let failure):
//                break
//            }
//        }
        
 disconnect printer
        
//        PrintManage.shared.disconnect(completion: { _ in })
        
 print invoice POS
        
 Supports 3 types - Image - String - Data
        
//        public enum PrintData {
//            case image(UIImage)
//            case text(String)
//            case data(Data)
//        }
        
//        PrintManage.shared.print(info: <#T##PrintInfomation#>,
//                                 printers: <#T##[Printer]#>,
//                                 handle: <#T##(PrintError?) -> Void#>)

