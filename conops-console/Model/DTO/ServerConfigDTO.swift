//
//  ServerConfigDTO.swift
//  Conops Console
//
//  Created by April White on 2/4/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

struct ServerConfigDTO: Codable {
    let useRemotePrinter: Bool
    let useReceiptPrinter: Bool
    let preRegMode: String?
    let remotePrinterUrl: String?
    let receiptPrinterHostname: String?
    let checkInSlipHeaderImageDirectory: String?
    let checkInSlipFooterImageDirectory: String?

    enum CodingKeys: String, CodingKey {
        case useRemotePrinter = "use_remote_printer"
        case useReceiptPrinter = "use_receipt_printer"
        case preRegMode = "pre_reg_mode"
        case remotePrinterUrl = "remote_printer_url"
        case receiptPrinterHostname = "receipt_printer_hostname"
        case checkInSlipHeaderImageDirectory = "check_in_slip_header_image_directory"
        case checkInSlipFooterImageDirectory = "check_in_slip_footer_image_directory"
    }
}
