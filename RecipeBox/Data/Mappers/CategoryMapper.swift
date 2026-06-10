import Foundation

enum CategoryMapper {
	static func map(_ dto: CategoryDTO) -> MealCategory {
		MealCategory(
			id: dto.idCategory,
			name: dto.strCategory,
			thumbnailURL: URL(string: dto.strCategoryThumb),
			description: dto.strCategoryDescription
		)
	}
}
