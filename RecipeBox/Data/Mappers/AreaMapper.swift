enum AreaMapper {
	static func map(_ dto: AreaDTO) -> Area {
		Area(name: dto.strArea)
	}
}
