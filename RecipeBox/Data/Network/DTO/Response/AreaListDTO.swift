import Foundation

/// `/list.php?a=list` — every culinary area, keyed (oddly) under `meals`.
struct AreaListDTO: Decodable {
	let meals: [AreaDTO]?
}

struct AreaDTO: Decodable {
	let strArea: String
}
