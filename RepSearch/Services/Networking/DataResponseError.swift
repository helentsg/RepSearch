//
//  NetworkRequestError.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//


enum DataResponseError: Error {
    
    case offline
    case network
    case decoding
    case limit
    case error(description: String)
    
    var description: String {
        switch self {
        case .offline:
            return "Нет подключения к интернету"
        case .network:
            return "Ошибка загрузки данных"
        case .decoding:
            return "Ошибка кодирования данных"
        case .limit:
            return "Исчерпан лимит обращений. Ещё 60 обращений возможны через час."
        case .error(let description):
            return description
        }
    }
}
