extends Control


const UiFactory = preload("res://scripts/ui_factory.gd")
const POSITIVE_COLOR: Color = Color(0.25, 0.87, 0.52, 1.0)
const NEGATIVE_COLOR: Color = Color(0.97, 0.38, 0.38, 1.0)
const NEUTRAL_COLOR: Color = Color(0.78, 0.82, 0.9, 1.0)

const SCREEN_INDEXES = {
	"market": 0,
	"savings": 1,
	"portfolio": 2,
	"budget": 3,
	"goals": 4
}

const TutorialData = preload("res://scripts/tutorial_data.gd")
const TUTORIAL_STEPS = TutorialData.STEPS


@onready var pages: TabContainer = $PageMargin/Content/Pages

@onready var date_label: Label = $PageMargin/Content/DateLabel
@onready var cash_label: Label = $PageMargin/Content/CashLabel
@onready var net_worth_label: Label = $PageMargin/Content/NetWorthLabel
@onready var report_label: Label = $PageMargin/Content/ReportLabel
@onready var end_week_button: Button = $PageMargin/Content/EndWeekButton

@onready var market_nav_button: Button = $PageMargin/Content/BottomNavigation/MarketNavButton
@onready var portfolio_nav_button: Button = $PageMargin/Content/BottomNavigation/PortfolioNavButton
@onready var savings_nav_button: Button = $PageMargin/Content/BottomNavigation/SavingsNavButton
@onready var budget_nav_button: Button = $PageMargin/Content/BottomNavigation/BudgetNavButton
@onready var goals_nav_button: Button = $PageMargin/Content/BottomNavigation/GoalsNavButton

@onready var news_label: Label = $PageMargin/Content/Pages/MarketPage/NewsLabel
@onready var company_list: VBoxContainer = $PageMargin/Content/Pages/MarketPage/MarketScroll/CompanyList

@onready var savings_balance_label: Label = $PageMargin/Content/Pages/SavingsPage/SavingsBalanceLabel
@onready var savings_rate_label: Label = $PageMargin/Content/Pages/SavingsPage/SavingsRateLabel
@onready var savings_amount_input: LineEdit = $PageMargin/Content/Pages/SavingsPage/SavingsAmountRow/SavingsAmountInput
@onready var deposit_button: Button = $PageMargin/Content/Pages/SavingsPage/SavingsButtons/DepositButton
@onready var withdraw_button: Button = $PageMargin/Content/Pages/SavingsPage/SavingsButtons/WithdrawButton

@onready var portfolio_cash_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioCashLabel
@onready var portfolio_savings_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioSavingsLabel
@onready var portfolio_companies_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioCompaniesLabel
@onready var portfolio_performance_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioPerformanceLabel
@onready var portfolio_debt_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioDebtLabel
@onready var portfolio_total_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioTotalLabel
@onready var portfolio_risk_label: Label = $PageMargin/Content/Pages/PortfolioPage/PortfolioRiskLabel
@onready var portfolio_company_list: VBoxContainer = $PageMargin/Content/Pages/PortfolioPage/PortfolioScroll/PortfolioCompanyList

@onready var budget_income_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetIncomeLabel
@onready var budget_expenses_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetExpensesLabel
@onready var budget_surplus_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetSurplusLabel
@onready var emergency_fund_label: Label = $PageMargin/Content/Pages/BudgetPage/EmergencyFundLabel
@onready var emergency_fund_progress: ProgressBar = $PageMargin/Content/Pages/BudgetPage/EmergencyFundProgress
@onready var budget_advice_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetAdviceLabel
@onready var budget_debt_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetDebtLabel
@onready var budget_debt_interest_label: Label = $PageMargin/Content/Pages/BudgetPage/BudgetDebtInterestLabel
@onready var pay_debt_button: Button = $PageMargin/Content/Pages/BudgetPage/PayDebtButton
@onready var loan_offer_status_label: Label = $PageMargin/Content/Pages/BudgetPage/LoanOfferStatusLabel
@onready var take_player_loan_button: Button = $PageMargin/Content/Pages/BudgetPage/TakePlayerLoanButton

@onready var chapter_progress_label: Label = $PageMargin/Content/Pages/GoalsPage/ChapterProgressLabel
@onready var chapter_progress_bar: ProgressBar = $PageMargin/Content/Pages/GoalsPage/ChapterProgressBar
@onready var goals_list_label: Label = $PageMargin/Content/Pages/GoalsPage/GoalsListLabel
@onready var goals_advice_label: Label = $PageMargin/Content/Pages/GoalsPage/GoalsAdviceLabel

@onready var stock_detail_overlay: ColorRect = $StockDetailOverlay
@onready var detail_back_button: Button = $StockDetailOverlay/DetailMargin/DetailContent/DetailTopBar/DetailBackButton
@onready var detail_title_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailTitleLabel
@onready var detail_sector_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailSectorLabel
@onready var detail_price_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPriceLabel
@onready var detail_change_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailChangeLabel
@onready var chart_area: Control = $StockDetailOverlay/DetailMargin/DetailContent/ChartPanel/ChartArea
@onready var price_line: Line2D = $StockDetailOverlay/DetailMargin/DetailContent/ChartPanel/ChartArea/PriceLine
@onready var detail_history_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailHistoryLabel
@onready var detail_shares_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPositionPanel/DetailPositionMargin/DetailStats/DetailSharesLabel
@onready var detail_average_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPositionPanel/DetailPositionMargin/DetailStats/DetailAverageLabel
@onready var detail_invested_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPositionPanel/DetailPositionMargin/DetailStats/DetailInvestedLabel
@onready var detail_unrealized_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPositionPanel/DetailPositionMargin/DetailStats/DetailUnrealizedLabel
@onready var detail_realized_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailPositionPanel/DetailPositionMargin/DetailStats/DetailRealizedLabel
@onready var detail_quantity_input: LineEdit = $StockDetailOverlay/DetailMargin/DetailContent/DetailQuantityRow/DetailQuantityInput
@onready var detail_buy_button: Button = $StockDetailOverlay/DetailMargin/DetailContent/DetailTradeButtons/DetailBuyButton
@onready var detail_sell_button: Button = $StockDetailOverlay/DetailMargin/DetailContent/DetailTradeButtons/DetailSellButton
@onready var detail_action_label: Label = $StockDetailOverlay/DetailMargin/DetailContent/DetailActionLabel

@onready var week_summary_overlay: ColorRect = $WeekSummaryOverlay
@onready var summary_week_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryWeekLabel
@onready var summary_headline_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryNewsPanel/SummaryNewsMargin/SummaryNewsContent/SummaryHeadlineLabel
@onready var summary_company_list: VBoxContainer = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryCompanyList
@onready var summary_portfolio_result_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryPortfolioResultLabel
@onready var summary_loan_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryLoanLabel
@onready var summary_monthly_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryMonthlyLabel
@onready var summary_consequence_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryConsequenceLabel
@onready var summary_explanation_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryExplanationLabel
@onready var summary_education_label: Label = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryScroll/SummaryBody/SummaryEducationLabel
@onready var summary_continue_button: Button = $WeekSummaryOverlay/SummaryMargin/SummaryContent/SummaryContinueButton

@onready var event_overlay: ColorRect = $EventOverlay
@onready var event_title_label: Label = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/EventTitleLabel
@onready var event_description_label: Label = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/EventDescriptionLabel
@onready var event_cost_label: Label = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/EventCostLabel
@onready var pay_cash_button: Button = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/PayCashButton
@onready var pay_savings_button: Button = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/PaySavingsButton
@onready var take_loan_button: Button = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/TakeLoanButton
@onready var restart_chapter_button: Button = $EventOverlay/EventCenter/EventPanel/EventMargin/EventContent/RestartChapterButton

@onready var start_overlay: ColorRect = $StartOverlay
@onready var continue_button: Button = $StartOverlay/StartCenter/StartPanel/StartMargin/StartContent/ContinueButton
@onready var new_game_button: Button = $StartOverlay/StartCenter/StartPanel/StartMargin/StartContent/NewGameButton
@onready var repeat_tutorial_button: Button = $StartOverlay/StartCenter/StartPanel/StartMargin/StartContent/RepeatTutorialButton
@onready var delete_save_button: Button = $StartOverlay/StartCenter/StartPanel/StartMargin/StartContent/DeleteSaveButton
@onready var start_status_label: Label = $StartOverlay/StartCenter/StartPanel/StartMargin/StartContent/StartStatusLabel

@onready var new_game_confirm_dialog: ConfirmationDialog = $NewGameConfirmDialog
@onready var delete_save_confirm_dialog: ConfirmationDialog = $DeleteSaveConfirmDialog

@onready var tutorial_overlay: ColorRect = $TutorialOverlay
@onready var tutorial_title_label: Label = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialTitleLabel
@onready var tutorial_step_label: Label = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialStepLabel
@onready var tutorial_progress_bar: ProgressBar = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialProgressBar
@onready var tutorial_description_label: Label = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialDescriptionLabel
@onready var tutorial_back_button: Button = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialButtons/TutorialBackButton
@onready var tutorial_next_button: Button = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialButtons/TutorialNextButton
@onready var tutorial_skip_button: Button = $TutorialOverlay/TutorialCenter/TutorialPanel/TutorialMargin/TutorialContent/TutorialSkipButton


var company_widgets: Dictionary = {}
var portfolio_widgets: Dictionary = {}
var navigation_buttons: Dictionary = {}
var selected_company_id: String = ""
var current_screen_id: String = "market"


func _ready() -> void:
	pages.set_tab_title(0, "RYNEK")
	pages.set_tab_title(1, "KONTO")
	pages.set_tab_title(2, "PORTFEL")
	pages.set_tab_title(3, "BUDŻET")
	pages.set_tab_title(4, "CELE")

	navigation_buttons = {
		"market": market_nav_button,
		"portfolio": portfolio_nav_button,
		"savings": savings_nav_button,
		"budget": budget_nav_button,
		"goals": goals_nav_button
	}

	_build_company_cards()
	_connect_buttons()
	_show_screen("market")

	if not GameState.state_changed.is_connected(update_ui):
		GameState.state_changed.connect(update_ui)

	update_ui()
	update_start_menu()


func _connect_buttons() -> void:
	for screen_id_value in navigation_buttons.keys():
		var screen_id: String = str(screen_id_value)
		var navigation_button: Button = navigation_buttons[screen_id]
		navigation_button.pressed.connect(_on_navigation_pressed.bind(screen_id))

	deposit_button.pressed.connect(_on_deposit_button_pressed)
	withdraw_button.pressed.connect(_on_withdraw_button_pressed)
	savings_amount_input.text_changed.connect(_on_savings_amount_changed)
	pay_debt_button.pressed.connect(_on_pay_debt_pressed)
	take_player_loan_button.pressed.connect(_on_take_player_loan_pressed)
	end_week_button.pressed.connect(_on_end_week_button_pressed)
	summary_continue_button.pressed.connect(_on_summary_continue_pressed)
	detail_back_button.pressed.connect(_on_detail_back_pressed)
	detail_buy_button.pressed.connect(_on_detail_buy_pressed)
	detail_sell_button.pressed.connect(_on_detail_sell_pressed)
	detail_quantity_input.text_changed.connect(_on_trade_quantity_changed)
	chart_area.resized.connect(_on_chart_area_resized)

	pay_cash_button.pressed.connect(_on_pay_cash_pressed)
	pay_savings_button.pressed.connect(_on_pay_savings_pressed)
	take_loan_button.pressed.connect(_on_take_loan_pressed)
	restart_chapter_button.pressed.connect(_on_restart_chapter_pressed)

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	repeat_tutorial_button.pressed.connect(_on_repeat_tutorial_pressed)
	delete_save_button.pressed.connect(_on_delete_save_pressed)
	new_game_confirm_dialog.confirmed.connect(_on_new_game_confirmed)
	delete_save_confirm_dialog.confirmed.connect(_on_delete_save_confirmed)

	tutorial_back_button.pressed.connect(_on_tutorial_back_pressed)
	tutorial_next_button.pressed.connect(_on_tutorial_next_pressed)
	tutorial_skip_button.pressed.connect(_on_tutorial_skip_pressed)


func _build_company_cards() -> void:
	company_widgets.clear()
	portfolio_widgets.clear()

	for old_child in company_list.get_children():
		old_child.queue_free()
	for old_child in portfolio_company_list.get_children():
		old_child.queue_free()

	for company_id_value in GameState.get_company_ids():
		var company_id: String = str(company_id_value)
		var definition: Dictionary = GameState.get_company_definition(company_id)
		_build_market_card(company_id, definition)
		_build_portfolio_card(company_id, definition)


func _build_market_card(company_id: String, definition: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 170)
	panel.add_theme_stylebox_override("panel", UiFactory.create_card_style())
	company_list.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)

	var name_label: Label = UiFactory.make_label("%s  •  %s" % [definition["name"], definition["ticker"]], 23, HORIZONTAL_ALIGNMENT_LEFT)
	content.add_child(name_label)

	var sector_label: Label = UiFactory.make_label("%s  •  ryzyko: %s" % [definition["sector"], str(definition["risk"]).to_lower()], 16, HORIZONTAL_ALIGNMENT_LEFT)
	sector_label.add_theme_color_override("font_color", NEUTRAL_COLOR)
	content.add_child(sector_label)

	var quote_row: HBoxContainer = HBoxContainer.new()
	quote_row.add_theme_constant_override("separation", 12)
	content.add_child(quote_row)
	var price_label: Label = UiFactory.make_label("0 M$", 25, HORIZONTAL_ALIGNMENT_LEFT)
	price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote_row.add_child(price_label)
	var change_label: Label = UiFactory.make_label("0%", 20, HORIZONTAL_ALIGNMENT_RIGHT)
	quote_row.add_child(change_label)

	var owned_label: Label = UiFactory.make_label("Nie posiadasz akcji", 16, HORIZONTAL_ALIGNMENT_LEFT)
	owned_label.add_theme_color_override("font_color", NEUTRAL_COLOR)
	content.add_child(owned_label)

	var details_button: Button = Button.new()
	details_button.custom_minimum_size = Vector2(0, 48)
	details_button.text = "ZOBACZ SZCZEGÓŁY"
	details_button.add_theme_font_size_override("font_size", 17)
	details_button.pressed.connect(_on_open_company_pressed.bind(company_id))
	content.add_child(details_button)

	company_widgets[company_id] = {
		"price_label": price_label,
		"change_label": change_label,
		"owned_label": owned_label
	}


func _build_portfolio_card(company_id: String, definition: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 148)
	panel.add_theme_stylebox_override("panel", UiFactory.create_card_style())
	panel.visible = false
	portfolio_company_list.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	margin.add_child(content)
	var name_label: Label = UiFactory.make_label("%s (%s)" % [definition["name"], definition["ticker"]], 21, HORIZONTAL_ALIGNMENT_LEFT)
	content.add_child(name_label)
	var position_label: Label = UiFactory.make_label("", 16, HORIZONTAL_ALIGNMENT_LEFT)
	position_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(position_label)
	var result_label: Label = UiFactory.make_label("", 18, HORIZONTAL_ALIGNMENT_LEFT)
	content.add_child(result_label)
	var details_button: Button = Button.new()
	details_button.custom_minimum_size = Vector2(0, 44)
	details_button.text = "OTWÓRZ SPÓŁKĘ"
	details_button.pressed.connect(_on_open_company_pressed.bind(company_id))
	content.add_child(details_button)

	portfolio_widgets[company_id] = {
		"panel": panel,
		"position_label": position_label,
		"result_label": result_label
	}


func _on_navigation_pressed(screen_id: String) -> void:
	_show_screen(screen_id)


func _show_screen(screen_id: String) -> void:
	if not SCREEN_INDEXES.has(screen_id):
		return
	current_screen_id = screen_id
	pages.current_tab = int(SCREEN_INDEXES[screen_id])
	for button_id_value in navigation_buttons.keys():
		var button_id: String = str(button_id_value)
		var navigation_button: Button = navigation_buttons[button_id]
		navigation_button.button_pressed = button_id == screen_id


func _on_open_company_pressed(company_id: String) -> void:
	selected_company_id = company_id
	detail_quantity_input.text = "1"
	stock_detail_overlay.visible = true
	detail_action_label.text = "Wybierz kupno albo sprzedaż."
	update_stock_detail()
	call_deferred("_update_price_chart")


func _on_detail_back_pressed() -> void:
	stock_detail_overlay.visible = false


func _on_detail_buy_pressed() -> void:
	if selected_company_id.is_empty():
		return
	var quantity: int = _parse_positive_integer(detail_quantity_input.text)
	if quantity <= 0:
		detail_action_label.text = "Wpisz poprawną liczbę akcji większą od zera."
		return
	var result: String = GameState.buy_stock(selected_company_id, quantity)
	report_label.text = result
	detail_action_label.text = result


func _on_detail_sell_pressed() -> void:
	if selected_company_id.is_empty():
		return
	var quantity: int = _parse_positive_integer(detail_quantity_input.text)
	if quantity <= 0:
		detail_action_label.text = "Wpisz poprawną liczbę akcji większą od zera."
		return
	var result: String = GameState.sell_stock(selected_company_id, quantity)
	report_label.text = result
	detail_action_label.text = result


func _on_trade_quantity_changed(_new_text: String) -> void:
	update_stock_detail()


func _on_chart_area_resized() -> void:
	if stock_detail_overlay.visible:
		_update_price_chart()


func update_stock_detail() -> void:
	if selected_company_id.is_empty() or not stock_detail_overlay.visible:
		return
	var definition: Dictionary = GameState.get_company_definition(selected_company_id)
	if definition.is_empty():
		stock_detail_overlay.visible = false
		return

	var price: int = GameState.get_company_price(selected_company_id)
	var shares: int = GameState.get_company_shares(selected_company_id)
	var change_percent: int = GameState.get_company_last_change_percent(selected_company_id)
	var average_price: float = GameState.get_company_average_buy_price(selected_company_id)
	var invested_amount: float = GameState.get_company_invested_amount(selected_company_id)
	var unrealized_profit: float = GameState.get_company_unrealized_profit(selected_company_id)
	var unrealized_percent: float = GameState.get_company_unrealized_percent(selected_company_id)
	var realized_profit: float = GameState.get_company_realized_profit(selected_company_id)
	var actions_blocked: bool = not GameState.can_make_financial_decisions()
	var quantity: int = _parse_positive_integer(detail_quantity_input.text)
	var transaction_value: int = price * quantity
	var quantity_invalid: bool = quantity <= 0

	detail_title_label.text = "%s (%s)" % [definition["name"], definition["ticker"]]
	detail_sector_label.text = "%s  •  Ryzyko: %s" % [definition["sector"], definition["risk"]]
	detail_price_label.text = "%s M$" % GameState.format_money(price)
	detail_change_label.text = "Zmiana tygodniowa: %s" % format_signed_percent(change_percent)
	detail_change_label.add_theme_color_override("font_color", get_result_color(change_percent))
	detail_shares_label.text = "Posiadane akcje: %d" % shares
	detail_average_label.text = "Średnia cena zakupu: %s M$" % GameState.format_money_decimal(average_price) if shares > 0 else "Średnia cena zakupu: —"
	detail_invested_label.text = "Zainwestowano: %s M$" % GameState.format_money_decimal(invested_amount)
	detail_unrealized_label.text = "Niezrealizowany wynik: %s M$ (%s)" % [format_signed_decimal_money(unrealized_profit), format_signed_percent_float(unrealized_percent)]
	detail_unrealized_label.add_theme_color_override("font_color", get_result_color(unrealized_profit))
	detail_realized_label.text = "Wynik ze sprzedaży: %s M$" % format_signed_decimal_money(realized_profit)
	detail_realized_label.add_theme_color_override("font_color", get_result_color(realized_profit))
	if quantity_invalid:
		detail_buy_button.text = "KUP AKCJE"
		detail_sell_button.text = "SPRZEDAJ AKCJE"
	else:
		detail_buy_button.text = "KUP %d • %s M$" % [
			quantity,
			GameState.format_money(transaction_value)
		]
		detail_sell_button.text = "SPRZEDAJ %d • %s M$" % [
			quantity,
			GameState.format_money(transaction_value)
		]
	detail_buy_button.disabled = (
		actions_blocked
		or quantity_invalid
		or GameState.cash < transaction_value
	)
	detail_sell_button.disabled = (
		actions_blocked
		or quantity_invalid
		or shares < quantity
	)
	_update_price_chart()


func _update_price_chart() -> void:
	if selected_company_id.is_empty():
		return
	var history: Array = GameState.get_company_price_history(selected_company_id)
	if history.is_empty():
		price_line.clear_points()
		return

	var minimum_price: float = float(history[0])
	var maximum_price: float = float(history[0])
	for price_value in history:
		minimum_price = min(minimum_price, float(price_value))
		maximum_price = max(maximum_price, float(price_value))
	var display_minimum: float = minimum_price
	var display_maximum: float = maximum_price
	if is_equal_approx(display_minimum, display_maximum):
		display_minimum -= max(1.0, display_minimum * 0.05)
		display_maximum += max(1.0, display_maximum * 0.05)

	var chart_width: float = max(120.0, chart_area.size.x)
	var chart_height: float = max(120.0, chart_area.size.y)
	var left_margin: float = 28.0
	var right_margin: float = 28.0
	var top_margin: float = 24.0
	var bottom_margin: float = 24.0
	var usable_width: float = chart_width - left_margin - right_margin
	var usable_height: float = chart_height - top_margin - bottom_margin
	var points: PackedVector2Array = PackedVector2Array()

	for index in range(history.size()):
		var x_ratio: float = float(index) / float(history.size() - 1) if history.size() > 1 else 0.0
		var price_value: float = float(history[index])
		var y_ratio: float = (price_value - display_minimum) / (display_maximum - display_minimum)
		points.append(Vector2(left_margin + usable_width * x_ratio, top_margin + usable_height * (1.0 - y_ratio)))
	if points.size() == 1:
		points.append(Vector2(chart_width - right_margin, points[0].y))

	price_line.points = points
	price_line.default_color = POSITIVE_COLOR if float(history[history.size() - 1]) >= float(history[0]) else NEGATIVE_COLOR
	detail_history_label.text = "Historia: %d tyg.  •  min. %s M$  •  maks. %s M$" % [history.size(), GameState.format_money(roundi(minimum_price)), GameState.format_money(roundi(maximum_price))]


func show_week_summary() -> void:
	var summary: Dictionary = GameState.last_week_summary
	if summary.is_empty():
		return

	stock_detail_overlay.visible = false
	summary_week_label.text = "TYDZIEŃ %d Z %d" % [
		int(summary.get("completed_week", 0)),
		GameState.CHAPTER_LENGTH_WEEKS
	]
	summary_headline_label.text = str(summary.get("headline", ""))

	for old_child in summary_company_list.get_children():
		summary_company_list.remove_child(old_child)
		old_child.queue_free()
	var company_results: Array = summary.get("companies", [])
	for result_value in company_results:
		_build_summary_company_card(result_value)

	var portfolio_change: int = int(summary.get("portfolio_change", 0))
	summary_portfolio_result_label.text = (
		"Zmiana Twoich akcji w tym tygodniu: %s M$"
		% GameState.format_signed_money(portfolio_change)
	)
	summary_portfolio_result_label.add_theme_color_override(
		"font_color",
		get_result_color(portfolio_change)
	)

	var loan_report: String = str(summary.get("loan_report", ""))
	summary_loan_label.visible = not loan_report.is_empty()
	summary_loan_label.text = "POŻYCZKA\n" + loan_report
	summary_loan_label.add_theme_color_override(
		"font_color",
		NEGATIVE_COLOR if bool(summary.get("loan_missed", false)) else NEUTRAL_COLOR
	)

	var monthly_report: String = str(summary.get("monthly_report", ""))
	summary_monthly_label.visible = not monthly_report.is_empty()
	summary_monthly_label.text = monthly_report
	var consequence_reports: Array = summary.get("consequence_reports", [])
	summary_consequence_label.visible = not consequence_reports.is_empty()
	summary_consequence_label.text = "KONSEKWENCJE WCZEŚNIEJSZYCH DECYZJI\n" + "\n\n".join(PackedStringArray(consequence_reports))
	summary_explanation_label.text = (
		"DLACZEGO TAK SIĘ STAŁO?\n%s"
		% str(summary.get("explanation", ""))
	)
	summary_education_label.text = _create_week_education(summary)

	if GameState.chapter_finished:
		summary_continue_button.text = "ZOBACZ PODSUMOWANIE ROZDZIAŁU"
	elif GameState.has_pending_story_decision():
		summary_continue_button.text = "PRZEJDŹ DO DECYZJI"
	elif GameState.has_pending_life_event():
		summary_continue_button.text = "PRZEJDŹ DO WYDARZENIA"
	else:
		summary_continue_button.text = "PRZEJDŹ DO TYGODNIA %d" % (
			GameState.get_chapter_week_number()
		)
	week_summary_overlay.visible = true


func _build_summary_company_card(result_value: Variant) -> void:
	var result: Dictionary = result_value
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 92)
	panel.add_theme_stylebox_override("panel", UiFactory.create_card_style())
	summary_company_list.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	var top_row: HBoxContainer = HBoxContainer.new()
	content.add_child(top_row)
	var name_label: Label = UiFactory.make_label(
		"%s (%s)" % [result["name"], result["ticker"]],
		19,
		HORIZONTAL_ALIGNMENT_LEFT
	)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(name_label)
	var change_percent: int = int(result["change_percent"])
	var change_label: Label = UiFactory.make_label(
		format_signed_percent(change_percent),
		19,
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	change_label.add_theme_color_override(
		"font_color",
		get_result_color(change_percent)
	)
	top_row.add_child(change_label)

	var position_text: String = "Nie posiadałeś akcji tej firmy."
	if int(result["shares"]) > 0:
		position_text = "Wpływ na Twój portfel: %s M$" % (
			GameState.format_signed_money(int(result["position_result"]))
		)
	var details_label: Label = UiFactory.make_label(
		"%s → %s M$  •  %s" % [
			GameState.format_money(int(result["old_price"])),
			GameState.format_money(int(result["new_price"])),
			position_text
		],
		16,
		HORIZONTAL_ALIGNMENT_LEFT
	)
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(details_label)


func _create_week_education(summary: Dictionary) -> String:
	var company_results: Array = summary.get("companies", [])
	var biggest_company_name: String = ""
	var biggest_position_result: int = 0
	var has_owned_stock: bool = false

	for result_value in company_results:
		var result: Dictionary = result_value
		if int(result.get("shares", 0)) <= 0:
			continue
		has_owned_stock = true
		var position_result: int = int(result.get("position_result", 0))
		if biggest_company_name.is_empty() or abs(position_result) > abs(biggest_position_result):
			biggest_company_name = str(result.get("name", ""))
			biggest_position_result = position_result

	var lesson: String = "LEKCJA TYGODNIA\n"
	if not has_owned_stock:
		lesson += (
			"Nie posiadałeś akcji, więc ruch rynku nie zmienił wartości "
			+ "Twojego portfela. Brak inwestycji też jest decyzją."
		)
	else:
		lesson += "Największy wpływ miała spółka %s: %s M$. " % [
			biggest_company_name,
			GameState.format_signed_money(biggest_position_result)
		]
		if GameState.get_owned_company_count() <= 1:
			lesson += "Jedna firma oznacza wysokie ryzyko koncentracji."
		else:
			lesson += "Kilka firm ogranicza wpływ pojedynczej złej wiadomości."

	if bool(summary.get("loan_missed", false)):
		lesson += (
			" Niepełna rata zwiększa koszt długu, dlatego przed inwestowaniem "
			+ "warto zachować gotówkę na najbliższe zobowiązania."
		)
	elif not str(summary.get("loan_report", "")).is_empty():
		lesson += (
			" Pożyczka zwiększyła wcześniej gotówkę, ale rata teraz zmniejsza "
			+ "płynność — pożyczone środki nie są dodatkowym majątkiem."
		)
	return lesson


func _on_deposit_button_pressed() -> void:
	var amount: int = _parse_positive_integer(savings_amount_input.text)
	if amount <= 0:
		report_label.text = "Wpisz poprawną kwotę większą od zera."
		return
	report_label.text = GameState.deposit_savings(amount)


func _on_withdraw_button_pressed() -> void:
	var amount: int = _parse_positive_integer(savings_amount_input.text)
	if amount <= 0:
		report_label.text = "Wpisz poprawną kwotę większą od zera."
		return
	report_label.text = GameState.withdraw_savings(amount)


func _on_savings_amount_changed(_new_text: String) -> void:
	_update_savings_controls(not GameState.can_make_financial_decisions())


func _parse_positive_integer(text_value: String) -> int:
	var clean_value: String = text_value.strip_edges().replace(" ", "")
	if clean_value.is_empty() or not clean_value.is_valid_int():
		return 0
	return max(0, int(clean_value))


func _on_pay_debt_pressed() -> void:
	report_label.text = GameState.repay_debt()


func _on_take_player_loan_pressed() -> void:
	report_label.text = GameState.take_player_loan()


func _on_end_week_button_pressed() -> void:
	report_label.text = GameState.end_week()
	if not GameState.last_week_summary.is_empty():
		show_week_summary()


func _on_summary_continue_pressed() -> void:
	week_summary_overlay.visible = false


func _on_pay_cash_pressed() -> void:
	if GameState.has_decision_feedback():
		GameState.dismiss_decision_feedback()
		report_label.text = "Konsekwencja zapisana. Możesz planować kolejny tydzień."
		return
	if GameState.has_pending_story_decision():
		_resolve_story_choice(0)
		return
	report_label.text = GameState.resolve_life_event("cash")


func _on_pay_savings_pressed() -> void:
	if GameState.has_pending_story_decision():
		_resolve_story_choice(1)
		return
	report_label.text = GameState.resolve_life_event("savings")


func _on_take_loan_pressed() -> void:
	if GameState.has_pending_story_decision():
		_resolve_story_choice(2)
		return
	report_label.text = GameState.resolve_life_event("loan")


func _resolve_story_choice(choice_index: int) -> void:
	report_label.text = GameState.resolve_story_decision(choice_index)


func _on_restart_chapter_pressed() -> void:
	GameState.start_new_game()
	stock_detail_overlay.visible = false
	week_summary_overlay.visible = false
	_show_screen("market")
	report_label.text = "Rozdział rozpoczęty od nowa. Podejmij pierwsze decyzje finansowe."
	update_tutorial_overlay()


func _on_continue_pressed() -> void:
	if GameState.load_game():
		start_overlay.visible = false
		stock_detail_overlay.visible = false
		week_summary_overlay.visible = false
		_show_screen("market")
		report_label.text = "Wczytano zapis gry. Możesz kontynuować od ostatniej decyzji."
		update_tutorial_overlay()
		return
	start_status_label.text = "Nie udało się wczytać zapisu. Możesz go usunąć i rozpocząć nową grę."
	update_start_menu_buttons()


func _on_new_game_pressed() -> void:
	if GameState.has_save_file():
		new_game_confirm_dialog.dialog_text = "Rozpoczęcie nowej gry zastąpi dotychczasowy zapis.\nCzy na pewno chcesz kontynuować?"
		new_game_confirm_dialog.popup_centered()
		return
	_begin_new_game()


func _on_new_game_confirmed() -> void:
	_begin_new_game()


func _begin_new_game() -> void:
	GameState.start_new_game()
	start_overlay.visible = false
	stock_detail_overlay.visible = false
	week_summary_overlay.visible = false
	_show_screen("market")
	report_label.text = "Rozpoczęto nową grę. Postęp będzie zapisywany automatycznie."
	update_tutorial_overlay()


func _on_repeat_tutorial_pressed() -> void:
	if not GameState.load_game():
		start_status_label.text = "Nie udało się wczytać zapisu potrzebnego do uruchomienia samouczka."
		update_start_menu_buttons()
		return
	GameState.restart_tutorial()
	start_overlay.visible = false
	stock_detail_overlay.visible = false
	week_summary_overlay.visible = false
	report_label.text = "Samouczek został uruchomiony ponownie."
	update_tutorial_overlay()


func _on_delete_save_pressed() -> void:
	if not GameState.has_save_file():
		update_start_menu()
		return
	delete_save_confirm_dialog.dialog_text = "Usuniętego zapisu nie będzie można odzyskać.\nCzy na pewno chcesz go usunąć?"
	delete_save_confirm_dialog.popup_centered()


func _on_delete_save_confirmed() -> void:
	if GameState.delete_save():
		start_status_label.text = "Zapis został usunięty. Możesz rozpocząć nową grę."
	else:
		start_status_label.text = "Nie udało się usunąć zapisu."
	update_start_menu_buttons()


func update_start_menu() -> void:
	var save_exists: bool = GameState.has_save_file()
	update_start_menu_buttons()
	start_status_label.text = "Znaleziono zapis gry. Możesz kontynuować albo zacząć od nowa.\nGra zapisuje postęp automatycznie po każdej decyzji." if save_exists else "Brak zapisu gry. Rozpocznij pierwszy rozdział.\nPostęp będzie zapisywany automatycznie."


func update_start_menu_buttons() -> void:
	var save_exists: bool = GameState.has_save_file()
	continue_button.disabled = not save_exists
	repeat_tutorial_button.disabled = not save_exists
	delete_save_button.disabled = not save_exists


func _on_tutorial_back_pressed() -> void:
	GameState.set_tutorial_step(GameState.tutorial_step - 1, TUTORIAL_STEPS.size())


func _on_tutorial_next_pressed() -> void:
	if GameState.tutorial_step >= TUTORIAL_STEPS.size() - 1:
		GameState.complete_tutorial()
		_show_screen("market")
		report_label.text = "Samouczek ukończony. Podejmij pierwszą decyzję finansową."
		return
	GameState.set_tutorial_step(GameState.tutorial_step + 1, TUTORIAL_STEPS.size())


func _on_tutorial_skip_pressed() -> void:
	GameState.complete_tutorial()
	_show_screen("market")
	report_label.text = "Samouczek pominięty. Możesz uruchomić go ponownie z menu startowego."


func update_tutorial_overlay() -> void:
	var show_tutorial: bool = GameState.is_tutorial_active() and not start_overlay.visible
	tutorial_overlay.visible = show_tutorial
	if not show_tutorial:
		return
	var step_index: int = clampi(GameState.tutorial_step, 0, TUTORIAL_STEPS.size() - 1)
	var tutorial_step_data: Dictionary = TUTORIAL_STEPS[step_index]
	_show_screen(str(tutorial_step_data["screen"]))
	tutorial_title_label.text = str(tutorial_step_data["title"])
	tutorial_step_label.text = "KROK %d Z %d" % [step_index + 1, TUTORIAL_STEPS.size()]
	tutorial_description_label.text = str(tutorial_step_data["text"])
	tutorial_progress_bar.min_value = 0.0
	tutorial_progress_bar.max_value = TUTORIAL_STEPS.size()
	tutorial_progress_bar.value = step_index + 1
	tutorial_back_button.disabled = step_index <= 0
	tutorial_next_button.text = "ZACZYNAMY" if step_index >= TUTORIAL_STEPS.size() - 1 else "DALEJ"


func update_ui() -> void:
	var net_worth: float = GameState.get_net_worth()
	var market_event: Dictionary = GameState.get_current_market_event()
	var actions_blocked: bool = not GameState.can_make_financial_decisions()
	date_label.text = "Rok %d • Miesiąc %d • Tydzień %d/4 • Rozdział %d/%d" % [GameState.current_year, GameState.current_month, GameState.current_week, GameState.get_chapter_week_number(), GameState.CHAPTER_LENGTH_WEEKS]
	cash_label.text = "Gotówka: %s M$" % GameState.format_money(GameState.cash)
	net_worth_label.text = "Majątek netto: %s M$" % GameState.format_money_decimal(net_worth)
	news_label.text = "WIADOMOŚĆ TYGODNIA\n\n%s" % market_event["headline"]

	_update_company_cards()
	savings_balance_label.text = "Saldo: %s M$" % GameState.format_money_decimal(GameState.savings_balance)
	savings_rate_label.text = "Oprocentowanie: 0,5% miesięcznie"
	_update_savings_controls(actions_blocked)
	pay_debt_button.disabled = actions_blocked or GameState.debt <= 0 or GameState.cash <= 0
	end_week_button.disabled = actions_blocked

	update_portfolio_ui(net_worth)
	update_budget_ui()
	update_goals_ui()
	update_event_overlay()
	update_tutorial_overlay()
	update_stock_detail()


func _update_savings_controls(actions_blocked: bool) -> void:
	var amount: int = _parse_positive_integer(savings_amount_input.text)
	var amount_invalid: bool = amount < GameState.SAVINGS_MIN_AMOUNT
	if amount <= 0:
		deposit_button.text = "WPŁAĆ"
		withdraw_button.text = "WYPŁAĆ"
	else:
		deposit_button.text = "WPŁAĆ %s M$" % GameState.format_money(amount)
		withdraw_button.text = "WYPŁAĆ %s M$" % GameState.format_money(amount)
	deposit_button.disabled = (
		actions_blocked
		or amount_invalid
		or GameState.cash < amount
	)
	withdraw_button.disabled = (
		actions_blocked
		or amount_invalid
		or GameState.savings_balance < amount
	)


func _update_company_cards() -> void:
	for company_id_value in GameState.get_company_ids():
		var company_id: String = str(company_id_value)
		var widgets: Dictionary = company_widgets[company_id]
		var price_label: Label = widgets["price_label"]
		var change_label: Label = widgets["change_label"]
		var owned_label: Label = widgets["owned_label"]
		var price: int = GameState.get_company_price(company_id)
		var shares: int = GameState.get_company_shares(company_id)
		var change_percent: int = GameState.get_company_last_change_percent(company_id)
		price_label.text = "%s M$ / akcję" % GameState.format_money(price)
		change_label.text = format_signed_percent(change_percent)
		change_label.add_theme_color_override("font_color", get_result_color(change_percent))
		owned_label.text = "Posiadasz: %d • wartość %s M$" % [shares, GameState.format_money_decimal(GameState.get_company_value(company_id))] if shares > 0 else "Nie posiadasz akcji"


func update_portfolio_ui(net_worth: float) -> void:
	var cash_value: float = GameState.cash
	var savings_value: float = GameState.savings_balance
	var stock_value: float = GameState.get_all_stock_value()
	var gross_assets: float = cash_value + savings_value + stock_value
	var invested_amount: float = GameState.get_total_invested_amount()
	var unrealized_profit: float = GameState.get_total_unrealized_profit()
	var realized_profit: float = GameState.get_total_realized_profit()

	portfolio_cash_label.text = "Gotówka: %s M$ (%s)" % [GameState.format_money_decimal(cash_value), format_percent(calculate_percent(cash_value, gross_assets))]
	portfolio_savings_label.text = "Oszczędności: %s M$ (%s)" % [GameState.format_money_decimal(savings_value), format_percent(calculate_percent(savings_value, gross_assets))]
	portfolio_companies_label.text = "Wartość akcji: %s M$ (%s)" % [GameState.format_money_decimal(stock_value), format_percent(calculate_percent(stock_value, gross_assets))] if stock_value > 0.0 else "Nie masz jeszcze żadnych akcji. Otwórz RYNEK, aby poznać spółki."
	portfolio_performance_label.text = "Wpłacono: %s M$ • Wynik: %s M$ • Sprzedaż: %s M$" % [GameState.format_money_decimal(invested_amount), format_signed_decimal_money(unrealized_profit), format_signed_decimal_money(realized_profit)]
	portfolio_performance_label.add_theme_color_override("font_color", get_result_color(unrealized_profit))
	portfolio_debt_label.text = "Dług: %s M$" % GameState.format_money(GameState.debt)
	portfolio_total_label.text = "Majątek netto: %s M$" % GameState.format_money_decimal(net_worth)
	portfolio_risk_label.text = create_portfolio_assessment(cash_value, savings_value, stock_value)

	for company_id_value in GameState.get_company_ids():
		var company_id: String = str(company_id_value)
		var widgets: Dictionary = portfolio_widgets[company_id]
		var panel: PanelContainer = widgets["panel"]
		var shares: int = GameState.get_company_shares(company_id)
		panel.visible = shares > 0
		if shares <= 0:
			continue
		var position_label: Label = widgets["position_label"]
		var result_label: Label = widgets["result_label"]
		var result: float = GameState.get_company_unrealized_profit(company_id)
		position_label.text = "%d akcji • średnia %s M$ • kurs %s M$ • wartość %s M$" % [shares, GameState.format_money_decimal(GameState.get_company_average_buy_price(company_id)), GameState.format_money(GameState.get_company_price(company_id)), GameState.format_money_decimal(GameState.get_company_value(company_id))]
		result_label.text = "Wynik: %s M$ (%s)" % [format_signed_decimal_money(result), format_signed_percent_float(GameState.get_company_unrealized_percent(company_id))]
		result_label.add_theme_color_override("font_color", get_result_color(result))


func create_portfolio_assessment(cash_value: float, savings_value: float, stock_value: float) -> String:
	var owned_companies: int = GameState.get_owned_company_count()
	var assessment: String = ""
	if stock_value <= 0.0:
		assessment = "Brak akcji: nie ponosisz ryzyka rynku, ale nie korzystasz z możliwego wzrostu spółek."
	elif owned_companies == 1:
		assessment = "Wysoka koncentracja: wszystkie akcje są w jednej firmie."
	elif owned_companies < GameState.REQUIRED_COMPANIES:
		assessment = "Częściowa dywersyfikacja: masz mniej niż trzy firmy."
	else:
		assessment = "Dobra dywersyfikacja: inwestycje obejmują co najmniej trzy firmy."
	var covered_months: float = (cash_value + savings_value) / GameState.get_monthly_expenses()
	assessment += " Płynne środki pokrywają około %s mies. wydatków." % format_decimal(covered_months)
	if GameState.debt > 0:
		assessment += " Masz dług z automatyczną ratą tygodniową."
	return assessment


func update_budget_ui() -> void:
	var current_income: int = GameState.get_monthly_income()
	var current_expenses: int = GameState.get_monthly_expenses()
	var monthly_surplus: int = current_income - current_expenses
	var emergency_target: float = GameState.EMERGENCY_FUND_TARGET
	var saved_amount: float = GameState.savings_balance
	var covered_months: float = saved_amount / current_expenses
	var missing_amount: float = max(0.0, emergency_target - saved_amount)
	budget_income_label.text = "Dochód: +%s M$" % GameState.format_money(current_income)
	budget_expenses_label.text = "Stałe wydatki: -%s M$" % GameState.format_money(current_expenses)
	budget_surplus_label.text = "Miesięczna nadwyżka: +%s M$" % GameState.format_money(monthly_surplus)
	emergency_fund_label.text = "Poduszka na koncie: %s / %s M$" % [GameState.format_money_decimal(saved_amount), GameState.format_money(GameState.EMERGENCY_FUND_TARGET)]
	emergency_fund_progress.min_value = 0.0
	emergency_fund_progress.max_value = emergency_target
	emergency_fund_progress.value = min(saved_amount, emergency_target)
	if saved_amount >= emergency_target:
		budget_advice_label.text = "Cel osiągnięty: masz co najmniej 5 400 M$ poduszki. Przy obecnych wydatkach to około %s mies." % format_decimal(covered_months)
	elif covered_months >= 1.0:
		budget_advice_label.text = "Oszczędności pokrywają około %s mies. wydatków. Do celu brakuje %s M$." % [format_decimal(covered_months), GameState.format_money_decimal(missing_amount)]
	else:
		budget_advice_label.text = "Poduszka nie pokrywa jeszcze miesiąca wydatków. Do celu brakuje %s M$." % GameState.format_money_decimal(missing_amount)
	budget_debt_label.text = "Pozostały dług: %s M$" % GameState.format_money(GameState.debt)
	if GameState.debt > 0:
		budget_debt_interest_label.text = (
			"Następna rata: %s M$ • w tym odsetki: %s M$\n"
			+ "Szacowany czas spłaty: %d tyg. • pełne/spóźnione raty: %d/%d"
		) % [
			GameState.format_money(GameState.get_next_loan_payment()),
			GameState.format_money(GameState.get_next_loan_interest()),
			GameState.get_estimated_loan_weeks(),
			GameState.loan_payments_made,
			GameState.missed_loan_payments
		]
	else:
		budget_debt_interest_label.text = "Brak aktywnego długu i rat tygodniowych."
	var repayment: int = min(GameState.DEBT_REPAY_AMOUNT, min(GameState.cash, GameState.debt))
	pay_debt_button.text = "NADPŁAĆ %s M$" % GameState.format_money(repayment) if repayment > 0 else "NADPŁAĆ DŁUG"

	if GameState.debt > 0:
		loan_offer_status_label.text = (
			"Masz aktywny dług. Nową pożyczkę można otrzymać dopiero "
			+ "po jego całkowitej spłacie."
		)
		take_player_loan_button.text = "NAJPIERW SPŁAĆ DŁUG"
	elif GameState.voluntary_loans_taken >= GameState.MAX_VOLUNTARY_LOANS:
		loan_offer_status_label.text = (
			"Dobrowolna pożyczka została już wykorzystana w tym rozdziale."
		)
		take_player_loan_button.text = "LIMIT POŻYCZKI WYKORZYSTANY"
	else:
		loan_offer_status_label.text = (
			"2 000 M$ • rata kapitału 250 M$ tygodniowo • "
			+ "1% odsetek tygodniowo od pozostałego długu. "
			+ "Tylko jedna dobrowolna pożyczka w rozdziale."
		)
		take_player_loan_button.text = "WEŹ 2 000 M$ POŻYCZKI"
	take_player_loan_button.disabled = not GameState.can_take_player_loan()


func update_goals_ui() -> void:
	var chapter_week: int = GameState.get_chapter_week_number()
	chapter_progress_label.text = "ROZDZIAŁ 1: PIERWSZY ROK • TYDZIEŃ %d/%d" % [chapter_week, GameState.CHAPTER_LENGTH_WEEKS]
	chapter_progress_bar.min_value = 0.0
	chapter_progress_bar.max_value = GameState.CHAPTER_LENGTH_WEEKS
	chapter_progress_bar.value = GameState.total_weeks_passed
	var goal_lines: PackedStringArray = []
	for goal_value in GameState.get_goal_statuses():
		var goal: Dictionary = goal_value
		var marker: String = "✓" if bool(goal["done"]) else "○"
		var line: String = "%s %s" % [marker, goal["title"]]
		var progress: String = str(goal["progress"])
		if not progress.is_empty():
			line += "  [%s]" % progress
		goal_lines.append(line)
	goals_list_label.text = "\n\n".join(goal_lines)
	var completed: int = GameState.get_completed_goal_count()
	var total_goals: int = GameState.get_goal_statuses().size()
	goals_advice_label.text = "Rozdział zakończony. Wykonane cele: %d/%d." % [completed, total_goals] if GameState.chapter_finished else "Postęp: %d/%d. Cel 5 400 M$ jest ambitny i może wymagać kilku prób." % [completed, total_goals]


func update_event_overlay() -> void:
	var show_summary: bool = GameState.chapter_finished
	var show_feedback: bool = GameState.has_decision_feedback()
	var show_story_decision: bool = GameState.has_pending_story_decision()
	var show_life_event: bool = GameState.has_pending_life_event()
	event_overlay.visible = show_summary or show_feedback or show_story_decision or show_life_event
	if not event_overlay.visible:
		return
	stock_detail_overlay.visible = false
	restart_chapter_button.visible = false
	pay_cash_button.visible = true
	pay_savings_button.visible = true
	take_loan_button.visible = true
	event_cost_label.add_theme_font_size_override("font_size", 24)
	if show_summary:
		event_title_label.text = "KONIEC ROZDZIAŁU 1"
		event_description_label.text = GameState.get_chapter_summary()
		event_cost_label.text = "Wynik celów: %d/%d" % [GameState.get_completed_goal_count(), GameState.get_goal_statuses().size()]
		pay_cash_button.visible = false
		pay_savings_button.visible = false
		take_loan_button.visible = false
		restart_chapter_button.visible = true
		return
	if show_feedback:
		var feedback: Dictionary = GameState.get_decision_feedback()
		var lesson_parts: PackedStringArray = []
		var future_note: String = str(feedback.get("future_note", ""))
		var education: String = str(feedback.get("education", ""))
		if not future_note.is_empty():
			lesson_parts.append(future_note)
		if not education.is_empty():
			lesson_parts.append("LEKCJA\n" + education)
		event_title_label.text = "SKUTEK DECYZJI"
		event_description_label.text = str(feedback.get("title", "DECYZJA")) + "\n\n" + str(feedback.get("result", "Decyzja została zapisana."))
		event_cost_label.text = "\n\n".join(lesson_parts)
		event_cost_label.add_theme_font_size_override("font_size", 18)
		pay_cash_button.text = "ROZUMIEM"
		pay_cash_button.disabled = false
		pay_savings_button.visible = false
		take_loan_button.visible = false
		return
	if show_story_decision:
		var decision: Dictionary = GameState.get_pending_story_decision()
		var choices: Array = decision.get("choices", [])
		var choice_buttons: Array[Button] = [pay_cash_button, pay_savings_button, take_loan_button]
		event_title_label.text = str(decision.get("title", "DECYZJA TYGODNIA"))
		event_description_label.text = str(decision.get("description", ""))
		event_cost_label.text = "WYBIERZ JEDNĄ OPCJĘ. Nie każda korzyść lub strata pojawi się od razu."
		event_cost_label.add_theme_font_size_override("font_size", 18)
		for choice_index in range(choice_buttons.size()):
			var choice_button: Button = choice_buttons[choice_index]
			choice_button.visible = choice_index < choices.size()
			if not choice_button.visible:
				continue
			var choice: Dictionary = choices[choice_index]
			choice_button.text = str(choice.get("title", "OPCJA")) + "\n" + str(choice.get("details", ""))
			choice_button.disabled = not GameState.can_choose_story_option(choice_index)
		return
	var life_event: Dictionary = GameState.get_pending_life_event()
	var cost: int = int(life_event["cost"])
	event_title_label.text = str(life_event["title"])
	event_description_label.text = str(life_event["description"])
	event_cost_label.text = "Koszt: %s M$" % GameState.format_money(cost)
	pay_cash_button.text = "ZAPŁAĆ GOTÓWKĄ"
	pay_savings_button.text = "UŻYJ OSZCZĘDNOŚCI"
	take_loan_button.text = "WEŹ POŻYCZKĘ"
	pay_cash_button.disabled = GameState.cash < cost
	pay_savings_button.disabled = GameState.savings_balance < cost
	take_loan_button.disabled = false


func get_result_color(value: float) -> Color:
	if value > 0.0:
		return POSITIVE_COLOR
	if value < 0.0:
		return NEGATIVE_COLOR
	return NEUTRAL_COLOR


func calculate_percent(value: float, total_value: float) -> float:
	if total_value <= 0.0:
		return 0.0
	return value / total_value * 100.0


func format_percent(value: float) -> String:
	return ("%.1f%%" % value).replace(".", ",")


func format_signed_percent(value: int) -> String:
	return "%s%d%%" % ["+" if value > 0 else "", value]


func format_signed_percent_float(value: float) -> String:
	var result: String = ("%.1f%%" % value).replace(".", ",")
	return "+" + result if value > 0.0 else result


func format_signed_decimal_money(value: float) -> String:
	var result: String = GameState.format_money_decimal(value)
	return "+" + result if value > 0.0 else result


func format_decimal(value: float) -> String:
	return ("%.1f" % value).replace(".", ",")
