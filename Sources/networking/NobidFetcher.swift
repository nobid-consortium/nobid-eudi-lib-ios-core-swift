/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import Foundation

public enum NobidFetchError: LocalizedError {
  case networkError(Error)
  case decodingError(Error)
  case invalidStatusCode(URL, Int)

  /**
   Provides a localized description of the fetch error.

   - Returns: A string describing the fetch error.
   */
  public var errorDescription: String? {
    switch self {
    case .networkError(let error):
      return ".networkError \(error.localizedDescription)"
    case .decodingError(let error):
      return ".decodingError \(error.localizedDescription)"
    case .invalidStatusCode(let code, let url):
      return ".invalidStatusCode \(code) \(url)"
    }
  }
}

public protocol NobidFetching {
  var session: URLSession { get set }

  associatedtype Element: Decodable

  /**
    Fetches data from the provided URL.

    - Parameters:
       - session: The URLSession to use for fetching the data.
       - url: The URL from which to fetch the data.

    - Returns: A `Result` type with the fetched data or an error.
   */
  func fetch(url: URL) async -> Result<Element, NobidFetchError>
}

public struct NobidFetcher<Element: Decodable>: NobidFetching {

  public var session: URLSession

  /**
   Initializes a Fetcher instance.
   */
  public init(
    session: URLSession = URLSession.shared
  ) {
    self.session = session
  }

  /**
   Fetches data from the provided URL.

   - Parameters:
      - url: The URL from which to fetch the data.

   - Returns: A Result type with the fetched data or an error.
   */
  public func fetch(url: URL) async -> Result<Element, NobidFetchError> {
    do {
      let (data, response) = try await self.session.data(from: url)
      NobidLogger.logResponse(subject: "NETWORK-NOBID", url: url, data: data, response: response)

      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if !(200...299).contains(statusCode) {
        throw NobidFetchError.invalidStatusCode(url, statusCode)
      }
      let object = try JSONDecoder().decode(Element.self, from: data)

      return .success(object)
    } catch let error as NSError {
      if error.domain == NSURLErrorDomain {
        return .failure(.networkError(error))
      } else {
        // <NOBID> invalid response format: Element.self
        NobidLogger.error("INVALID RESPONSE FORMAT. For valid format, see class: \(Element.self); Request URL: \(url); error=\(error);")
        return .failure(.decodingError(error))
      }
    } catch {
      return .failure(.decodingError(error))
    }
  }

  public func fetchString(url: URL) async throws -> Result<String, NobidFetchError> {
    do {
      let (data, response) = try await self.session.data(from: url)
      NobidLogger.logResponse(subject: "NETWORK-NOBID", url: url, data: data, response: response)

      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if !(200...299).contains(statusCode) {
        throw NobidFetchError.invalidStatusCode(url, statusCode)
      }

      if let string = String(data: data, encoding: .utf8) {
        return .success(string)

      } else {

        let error = NSError(
          domain: "com.networking",
          code: 0,
          userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"]
        )
        NobidLogger.error("INVALID RESPONSE FORMAT. Response data can't be parsed as string; Request URL: \(url);")
        return .failure(.decodingError(error))
      }
    }
  }
}


public struct NobidSimpleFetcher {

  public var session: URLSession

  /**
   Initializes a Fetcher instance.
   */
  public init(
    session: URLSession = URLSession.shared
  ) {
    self.session = session
  }
    public func fetchString(url: URL) async throws -> String? {
      do {
        let (data, response) = try await self.session.data(from: url)
        NobidLogger.logResponse(subject: "NETWORK-NOBID", url: url, data: data, response: response)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
          if !(200...299).contains(statusCode) {
          throw NobidFetchError.invalidStatusCode(url, statusCode)
        }

        if let string = String(data: data, encoding: .utf8) {
          return string

        } else {

          let error = NSError(
            domain: "com.networking",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"]
          )
          NobidLogger.error("INVALID RESPONSE FORMAT. Response data can't be parsed as string; Request URL: \(url);")
          return nil
        }
      }
    }
  }
