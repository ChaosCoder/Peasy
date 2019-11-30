//
//  Connection.swift
//  IntegratedMockTestUITests
//
//  Created by Kane Cheshire on 28/11/2019.
//  Copyright © 2019 kane.codes. All rights reserved.
//

import Foundation
import UIKit

final class Connection {
	
	typealias EventHandler = (Event, Connection) -> Void
	
	enum Event {
		case requestReceived(Request)
		case closed
	}
	
	private let uuid = UUID()
	private let handler: EventHandler
    private let client: Socket
	private var parser = RequestParser()
    private var inputLoop: InputLoop?
	
	init(client: Socket, handler: @escaping EventHandler) {
        self.client = client
        self.handler = handler
        inputLoop = InputLoop(socket: client) { [weak self] in // TODO: Not convinced this loop is even needed now
            self?.handleDataAvailable()
        }
	}
	
	func respond(to request: Request, with data: Data, completion: @escaping () -> Void) {
        client.write(data)
		close() // TODO: Maybe all managed from the Server?
		completion()
	}
	
	func close() {
		client.close()
	}
	
    private func handleDataAvailable() {
        switch client.read() {
            case .success(let data): handle(data)
            case .failure(let error): fatalError(error.message)
        }
    }
    
    private func handle(_ data: Data) {
        switch parser.parse(data) {
            case .finished(let request): handler(.requestReceived(request), self)
            case .notStarted, .receivingHeader, .receivingBody: break
        }
    }
    
}

extension Connection: Hashable {
	
	static func == (lhs: Connection, rhs: Connection) -> Bool {
		return lhs.uuid == rhs.uuid
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
	
}
