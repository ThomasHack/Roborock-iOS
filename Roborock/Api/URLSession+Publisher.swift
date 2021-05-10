//
//  URLSession+Publisher.swift
//  Roborock
//
//  Created by Thomas Hack on 09.05.21.
//

import Foundation
import Combine

fileprivate class CancellableStore {
    static let shared = CancellableStore()
    var cancellables = Set<AnyCancellable>()
}

public enum DownloadOutput {
    case complete(Data)
    case downloading(transferred: Int64 = 0, expected: Int64 = 0) // cumulative bytes transferred, total bytes expected
}

public enum UploadOutput: Equatable {
  case complete(Data?) // response body data, if any
  case uploading(transferred: Int64 = 0, expected: Int64 = 0) // cumulative bytes transferred, total bytes expected
}

extension URLSession {
    
    public func uploadTaskPublisher(with request: URLRequest, data: Data?) -> AnyPublisher<UploadOutput, Error> {
      
        let subject = PassthroughSubject<UploadOutput, Error>()
        
        let task = uploadTask(with: request, from: data) {
          (responseData, response, error) in
          
          guard error == nil else {
            subject.send(completion: .failure(error!))
            return
          }
          
          guard let httpResponse = response as? HTTPURLResponse else {
            let error = TransferError.urlError(URLError(.badServerResponse))
            subject.send(completion: .failure(error))
            return
          }
          
          // should be 201, but could vary
          guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
            let error = TransferError.httpError(httpResponse)
            subject.send(completion: .failure(error))
            return
          }
          
          subject.send(.complete(data)) // maybe don't publish at all if nil
          subject.send(completion: .finished)

        }
        
        task.taskDescription = request.url?.absoluteString
        
        let receivedPublisher = task.publisher(for: \.countOfBytesSent)
          .debounce(for: .seconds(0.1), scheduler: RunLoop.current) // adjust
         
        let expectedPublisher = task.publisher(for: \.countOfBytesExpectedToSend, options: [.initial, .new])
        
        Publishers.CombineLatest(receivedPublisher, expectedPublisher)
          .sink {
            let (received, expected) = $0
            let output = UploadOutput.uploading(transferred: received, expected: expected)
            subject.send(output)
        }.store(in: &CancellableStore.shared.cancellables)
        
        task.resume()
        
        return subject.eraseToAnyPublisher()
        
      }
}

// MARK: Error Types
public enum TransferError: Error {
    case httpError(HTTPURLResponse)
    case urlError(URLError)
}
