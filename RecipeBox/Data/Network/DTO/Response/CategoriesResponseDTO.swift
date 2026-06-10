import Foundation

/// `/categories.php` — the full category list with artwork and descriptions.
struct CategoriesResponseDTO: Decodable {
	let categories: [CategoryDTO]
}

struct CategoryDTO: Decodable {
	let idCategory: String
	let strCategory: String
	let strCategoryThumb: String
	let strCategoryDescription: String
}
