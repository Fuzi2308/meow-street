extends RefCounted


static func create_card_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.082, 0.11, 0.18, 1.0)
	style.border_color = Color(0.18, 0.24, 0.34, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	return style


static func make_label(
	text_value: String,
	font_size: int,
	alignment: HorizontalAlignment
) -> Label:
	var new_label: Label = Label.new()
	new_label.text = text_value
	new_label.horizontal_alignment = alignment
	new_label.add_theme_font_size_override("font_size", font_size)
	return new_label
