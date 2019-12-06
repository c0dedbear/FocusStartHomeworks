//
//  Rpository.swift
//  MarvelHeroes
//
//  Created by Stanislav on 06/12/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import Foundation

final class Repository
{
	private let session = URLSession(configuration: .default)
	private var dataTask: URLSessionDataTask?
// MARK: - Загрузка списков
// Загрузить список сущностей
	func loadEntities<T: Decodable>(with nameStarts: String = "",
									directory: String,
									queryParameter: String,
						completion: @escaping (Result<T, NSError>) -> Void)  {
		var additionParameters: [URLQueryItem] = []
		if nameStarts.isEmpty == false {
			additionParameters.append(URLQueryItem(name: queryParameter, value: nameStarts))
		}
		fetchData(directory: directory, additionParameters: additionParameters){ result in
			switch result {
			case .success(let data):
				do {
					let resultData = try JSONDecoder().decode(T.self, from: data)
					DispatchQueue.main.async {
						completion(.success(resultData))
					}
				}
				catch {
					DispatchQueue.main.async {
						completion( .failure(NSError()))
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					completion( .failure(error))
				}
			}
		}
	}
// MARK: - Загрузка по ID
//Загрузить доп список для сущности
	func loadAccessoryByEntityID<T: Decodable>(from directory: String,
						completion: @escaping (Result<T, NSError>) -> Void)  {
		fetchData(directory: directory){ result in
			switch result {
			case .success(let data):
				do {
					let resultData = try JSONDecoder().decode(T.self, from: data)
					DispatchQueue.main.async {
						completion(.success(resultData))
					}
				}
				catch {
					DispatchQueue.main.async {
						completion( .failure(NSError()))
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					completion( .failure(error))
				}
			}
		}
	}
}
// MARK: - Приватные методы
private extension Repository
{
// Загрузка данных
	func fetchData(directory: String,
						   additionParameters: [URLQueryItem] = [],
						   _ completion: @escaping (Result<Data, NSError>) -> Void ) {
		dataTask?.cancel()
		var urlComponent = URLComponents(string: Constants.marvelAPIUrl + directory)
		urlComponent?.queryItems = [
			URLQueryItem(name: "limit", value: String(Constants.limit)),
			URLQueryItem(name: "apikey", value: Constants.publicKey),
			URLQueryItem(name: "ts", value: Constants.ts),
			URLQueryItem(name: "hash", value: Constants.hash),
		]
		if urlComponent?.queryItems != nil {
			urlComponent?.queryItems? += additionParameters
		}
		else {
			urlComponent?.queryItems = additionParameters
		}
		guard let url = urlComponent?.url else { return }
		print(url)
		dataTask = session.dataTask(with: url) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					completion( .failure(error as NSError))
				}
			}
			if let response = response as? HTTPURLResponse, response.statusCode != 200 {
				DispatchQueue.main.async {
					completion( .failure(NSError()))
				}
			}
			if let data = data {
				completion( .success(data))
			}
			else {
				DispatchQueue.main.async {
					completion( .failure(NSError()))
				}
			}
		}
		dataTask?.resume()
	}
}
