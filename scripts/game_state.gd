extends Node


signal state_changed


const SAVE_PATH: String = "user://meow_street_save.json"
const SAVE_VERSION: int = 7

const STARTING_CASH: int = 2500
const CHAPTER_LENGTH_WEEKS: int = 48

const MONTHLY_INCOME: int = 2500
const MONTHLY_EXPENSES: int = 1800

const SAVINGS_DEFAULT_AMOUNT: int = 500
const SAVINGS_MIN_AMOUNT: int = 50
const REGULAR_SAVING_MIN_AMOUNT: int = 100
const SAVINGS_MONTHLY_RATE: float = 0.005
const EMERGENCY_FUND_TARGET: int = 5400
const REQUIRED_SAVING_WEEKS: int = 12
const REQUIRED_COMPANIES: int = 3
const REQUIRED_LIFE_EVENTS: int = 4

const DEBT_REPAY_AMOUNT: int = 500
const PLAYER_LOAN_AMOUNT: int = 2000
const LOAN_WEEKLY_PRINCIPAL: int = 250
const LOAN_WEEKLY_RATE: float = 0.01
const MAX_VOLUNTARY_LOANS: int = 1


const MarketData = preload("res://scripts/market_data.gd")
const StoryData = preload("res://scripts/story_data.gd")

const COMPANY_ORDER = MarketData.COMPANY_ORDER
const COMPANY_DEFINITIONS = MarketData.COMPANY_DEFINITIONS
const MARKET_EVENTS = MarketData.MARKET_EVENTS
const LIFE_EVENTS = MarketData.LIFE_EVENTS


var current_week: int = 1
var current_month: int = 1
var current_year: int = 1
var total_weeks_passed: int = 0

var cash: int = STARTING_CASH
var savings_balance: float = 0.0
var debt: int = 0
var monthly_income_bonus: int = 0
var monthly_expense_modifier: int = 0
var voluntary_loans_taken: int = 0
var loan_payments_made: int = 0
var missed_loan_payments: int = 0
var total_loan_interest_charged: int = 0

var companies: Dictionary = {}
var current_market_event_index: int = -1

var pending_life_event: Dictionary = {}
var next_life_event_week: int = 3
var last_life_event_index: int = -1
var used_life_event_indices: Array = []
var life_events_resolved: int = 0

var pending_story_decision: Dictionary = {}
var story_decision_history: Array = []
var decision_history: Array = []
var scheduled_consequences: Array = []
var consequence_history: Array = []
var decision_feedback: Dictionary = {}
var story_decisions_resolved: int = 0

var saving_weeks: Dictionary = {}
var first_stock_bought: bool = false
var chapter_finished: bool = false
var tutorial_step: int = 0
var tutorial_completed: bool = false
var last_week_summary: Dictionary = {}
var chapter_stats: Dictionary = {}


func _ready() -> void:
	randomize()
	reset_game(false, false)


func reset_game(
	emit_update: bool = true,
	save_after_reset: bool = false
) -> void:
	current_week = 1
	current_month = 1
	current_year = 1
	total_weeks_passed = 0

	cash = STARTING_CASH
	savings_balance = 0.0
	debt = 0
	monthly_income_bonus = 0
	monthly_expense_modifier = 0
	voluntary_loans_taken = 0
	loan_payments_made = 0
	missed_loan_payments = 0
	total_loan_interest_charged = 0

	_initialize_companies()
	current_market_event_index = -1
	_choose_next_market_event()

	pending_life_event = {}
	next_life_event_week = randi_range(5, 7)
	last_life_event_index = -1
	used_life_event_indices.clear()
	life_events_resolved = 0

	pending_story_decision = {}
	story_decision_history.clear()
	decision_history.clear()
	scheduled_consequences.clear()
	consequence_history.clear()
	decision_feedback = {}
	story_decisions_resolved = 0

	saving_weeks.clear()
	first_stock_bought = false
	chapter_finished = false
	tutorial_step = 0
	tutorial_completed = false
	last_week_summary = {}
	chapter_stats = _create_empty_chapter_stats()

	if save_after_reset:
		save_game()

	if emit_update:
		state_changed.emit()


func start_new_game() -> void:
	reset_game(true, true)


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	_update_stat_extremes()
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if save_file == null:
		return false

	var saving_week_numbers: Array = []

	for week_value in saving_weeks.keys():
		saving_week_numbers.append(int(week_value))

	var save_data: Dictionary = {
		"save_version": SAVE_VERSION,
		"current_week": current_week,
		"current_month": current_month,
		"current_year": current_year,
		"total_weeks_passed": total_weeks_passed,
		"cash": cash,
		"savings_balance": savings_balance,
		"debt": debt,
		"monthly_income_bonus": monthly_income_bonus,
		"monthly_expense_modifier": monthly_expense_modifier,
		"voluntary_loans_taken": voluntary_loans_taken,
		"loan_payments_made": loan_payments_made,
		"missed_loan_payments": missed_loan_payments,
		"total_loan_interest_charged": total_loan_interest_charged,
		"companies": companies,
		"current_market_event_index": current_market_event_index,
		"pending_life_event": pending_life_event,
		"next_life_event_week": next_life_event_week,
		"last_life_event_index": last_life_event_index,
		"used_life_event_indices": used_life_event_indices,
		"life_events_resolved": life_events_resolved,
		"pending_story_decision": pending_story_decision,
		"story_decision_history": story_decision_history,
		"decision_history": decision_history,
		"scheduled_consequences": scheduled_consequences,
		"consequence_history": consequence_history,
		"decision_feedback": decision_feedback,
		"story_decisions_resolved": story_decisions_resolved,
		"saving_week_numbers": saving_week_numbers,
		"first_stock_bought": first_stock_bought,
		"chapter_finished": chapter_finished,
		"tutorial_step": tutorial_step,
		"tutorial_completed": tutorial_completed,
		"chapter_stats": chapter_stats
	}

	save_file.store_string(JSON.stringify(save_data))
	save_file.close()
	return true


func load_game() -> bool:
	if not has_save_file():
		return false

	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if save_file == null:
		return false

	var json_text: String = save_file.get_as_text()
	save_file.close()

	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(json_text)

	if parse_error != OK:
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		return false

	var save_data: Dictionary = json.data

	var loaded_save_version: int = int(save_data.get("save_version", 0))

	if loaded_save_version <= 0 or loaded_save_version > SAVE_VERSION:
		return false

	_apply_save_data(save_data)
	# Zapisuje ewentualną migrację starszego zapisu oraz przygotowany wynik
	# decyzji. Dzięki temu ponowne uruchomienie gry nie losuje go ponownie.
	save_game()
	state_changed.emit()
	return true


func delete_save() -> bool:
	if not has_save_file():
		return true

	var absolute_save_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	return DirAccess.remove_absolute(absolute_save_path) == OK


func _apply_save_data(save_data: Dictionary) -> void:
	current_week = int(save_data.get("current_week", 1))
	current_month = int(save_data.get("current_month", 1))
	current_year = int(save_data.get("current_year", 1))
	total_weeks_passed = int(save_data.get("total_weeks_passed", 0))

	cash = int(save_data.get("cash", STARTING_CASH))
	savings_balance = float(save_data.get("savings_balance", 0.0))
	debt = int(save_data.get("debt", 0))
	monthly_income_bonus = int(save_data.get("monthly_income_bonus", 0))
	monthly_expense_modifier = int(save_data.get("monthly_expense_modifier", 0))
	voluntary_loans_taken = int(save_data.get("voluntary_loans_taken", 0))
	loan_payments_made = int(save_data.get("loan_payments_made", 0))
	missed_loan_payments = int(save_data.get("missed_loan_payments", 0))
	total_loan_interest_charged = int(
		save_data.get("total_loan_interest_charged", 0)
	)
	last_week_summary = {}

	_initialize_companies()
	var saved_companies: Dictionary = save_data.get("companies", {})

	for company_id_value in COMPANY_ORDER:
		var company_id: String = str(company_id_value)

		if not saved_companies.has(company_id):
			continue

		var saved_company: Dictionary = saved_companies[company_id]
		var saved_price: int = max(
			1,
			int(saved_company.get("price", get_company_price(company_id)))
		)
		var saved_shares: int = max(
			0,
			int(saved_company.get("shares", 0))
		)
		var saved_average: float = float(
			saved_company.get(
				"average_buy_price",
				float(saved_price) if saved_shares > 0 else 0.0
			)
		)
		var saved_history: Array = saved_company.get(
			"price_history",
			[saved_price]
		)
		var clean_history: Array = []

		for price_value in saved_history:
			clean_history.append(max(1, int(price_value)))

		if clean_history.is_empty():
			clean_history.append(saved_price)

		while clean_history.size() > 12:
			clean_history.pop_front()

		companies[company_id] = {
			"price": saved_price,
			"shares": saved_shares,
			"average_buy_price": max(0.0, saved_average),
			"realized_profit": float(saved_company.get("realized_profit", 0.0)),
			"last_change_percent": int(saved_company.get("last_change_percent", 0)),
			"price_history": clean_history
		}

	current_market_event_index = int(save_data.get("current_market_event_index", -1))

	if current_market_event_index < 0 or current_market_event_index >= MARKET_EVENTS.size():
		_choose_next_market_event()

	pending_life_event = save_data.get("pending_life_event", {})
	next_life_event_week = int(save_data.get("next_life_event_week", 3))
	last_life_event_index = int(save_data.get("last_life_event_index", -1))

	used_life_event_indices.clear()
	var saved_event_indices: Array = save_data.get("used_life_event_indices", [])

	for index_value in saved_event_indices:
		used_life_event_indices.append(int(index_value))

	life_events_resolved = int(save_data.get("life_events_resolved", 0))
	pending_story_decision = save_data.get("pending_story_decision", {})
	story_decision_history = save_data.get("story_decision_history", [])
	decision_history = save_data.get("decision_history", [])
	if decision_history.is_empty() and not story_decision_history.is_empty():
		for old_decision_id_value in story_decision_history:
			var old_decision_id: String = str(old_decision_id_value)
			var old_summary: Dictionary = StoryData.get_decision_summary_by_id(old_decision_id)
			if old_summary.is_empty():
				continue
			decision_history.append({
				"decision_id": old_decision_id,
				"week": int(old_summary.get("week", 0)),
				"title": str(old_summary.get("title", "DECYZJA")),
				"choice": "Decyzja podjęta przed aktualizacją",
				"risk": "BRAK DANYCH",
				"risk_note": "",
				"result": "Poprzednia wersja zapisu nie przechowywała szczegółów tego wyboru.",
				"education": "",
				"pending_consequences": 0
			})
	scheduled_consequences = save_data.get("scheduled_consequences", [])
	consequence_history = save_data.get("consequence_history", [])
	decision_feedback = save_data.get("decision_feedback", {})
	story_decisions_resolved = int(save_data.get("story_decisions_resolved", story_decision_history.size()))

	saving_weeks.clear()
	var saved_saving_weeks: Array = save_data.get("saving_week_numbers", [])

	for week_value in saved_saving_weeks:
		saving_weeks[int(week_value)] = true

	first_stock_bought = bool(save_data.get("first_stock_bought", false))
	chapter_finished = bool(save_data.get("chapter_finished", false))
	if int(save_data.get("save_version", SAVE_VERSION)) < 5:
		chapter_finished = total_weeks_passed >= CHAPTER_LENGTH_WEEKS
	tutorial_step = max(0, int(save_data.get("tutorial_step", 0)))
	tutorial_completed = bool(save_data.get("tutorial_completed", false))
	chapter_stats = _normalize_chapter_stats(save_data.get("chapter_stats", {}))
	if not save_data.has("chapter_stats"):
		_rebuild_migrated_decision_stats()
	_update_stat_extremes()
	if not pending_story_decision.is_empty() and not bool(pending_story_decision.get("outcomes_prepared", false)):
		var refreshed_decision: Dictionary = StoryData.get_decision_for_week(get_chapter_week_number())
		if str(refreshed_decision.get("id", "")) == str(pending_story_decision.get("id", "")):
			pending_story_decision = _prepare_story_decision(refreshed_decision)
	_trigger_story_decision_if_needed()


func _commit_state() -> void:
	_update_stat_extremes()
	save_game()
	state_changed.emit()


func _create_empty_chapter_stats() -> Dictionary:
	return {
		"tracking_started_week": total_weeks_passed,
		"weeks_recorded": 0,
		"safe_liquidity_weeks": 0,
		"critical_liquidity_weeks": 0,
		"minimum_cash": cash,
		"minimum_liquid_assets": cash + savings_balance,
		"maximum_savings": savings_balance,
		"peak_debt": debt,
		"maximum_owned_companies": get_owned_company_count(),
		"total_income_received": 0,
		"total_expenses_paid": 0,
		"total_savings_interest": 0.0,
		"total_savings_deposited": 0.0,
		"total_savings_withdrawn": 0.0,
		"total_stock_purchases": 0,
		"total_stock_sales": 0,
		"total_story_income": 0,
		"total_story_spending": 0,
		"total_unplanned_costs": 0,
		"life_event_costs_total": 0,
		"life_events_paid_cash": 0,
		"life_events_paid_savings": 0,
		"life_events_financed_by_loan": 0,
		"low_risk_decisions": 0,
		"medium_risk_decisions": 0,
		"high_risk_decisions": 0,
		"unsafe_high_risk_decisions": 0
	}


func _normalize_chapter_stats(saved_stats_value: Variant) -> Dictionary:
	var defaults: Dictionary = _create_empty_chapter_stats()
	if typeof(saved_stats_value) != TYPE_DICTIONARY:
		return defaults
	var saved_stats: Dictionary = saved_stats_value
	for stat_key_value in defaults.keys():
		var stat_key: String = str(stat_key_value)
		if saved_stats.has(stat_key):
			defaults[stat_key] = saved_stats[stat_key]
	return defaults


func _rebuild_migrated_decision_stats() -> void:
	chapter_stats["tracking_started_week"] = total_weeks_passed
	for history_value in decision_history:
		var history_entry: Dictionary = history_value
		var risk: String = str(history_entry.get("risk", "")).to_upper()
		if risk == "NISKIE":
			_add_stat("low_risk_decisions", 1)
		elif risk == "ŚREDNIE":
			_add_stat("medium_risk_decisions", 1)
		elif risk == "WYSOKIE":
			_add_stat("high_risk_decisions", 1)


func _add_stat(stat_name: String, amount: Variant) -> void:
	chapter_stats[stat_name] = chapter_stats.get(stat_name, 0) + amount


func _update_stat_extremes() -> void:
	if chapter_stats.is_empty():
		return
	var liquid_assets: float = cash + savings_balance
	chapter_stats["minimum_cash"] = min(
		float(chapter_stats.get("minimum_cash", cash)),
		float(cash)
	)
	chapter_stats["minimum_liquid_assets"] = min(
		float(chapter_stats.get("minimum_liquid_assets", liquid_assets)),
		liquid_assets
	)
	chapter_stats["maximum_savings"] = max(
		float(chapter_stats.get("maximum_savings", 0.0)),
		savings_balance
	)
	chapter_stats["peak_debt"] = max(
		int(chapter_stats.get("peak_debt", 0)),
		debt
	)
	chapter_stats["maximum_owned_companies"] = max(
		int(chapter_stats.get("maximum_owned_companies", 0)),
		get_owned_company_count()
	)


func _record_completed_week_statistics() -> void:
	_add_stat("weeks_recorded", 1)
	var liquid_assets: float = cash + savings_balance
	if liquid_assets >= get_monthly_expenses():
		_add_stat("safe_liquidity_weeks", 1)
	if liquid_assets < get_monthly_expenses() * 0.5:
		_add_stat("critical_liquidity_weeks", 1)
	_update_stat_extremes()


func is_tutorial_active() -> bool:
	return not tutorial_completed


func set_tutorial_step(step: int, step_count: int) -> void:
	if step_count <= 0:
		return

	tutorial_step = clampi(step, 0, step_count - 1)
	_commit_state()


func complete_tutorial() -> void:
	tutorial_completed = true
	_trigger_story_decision_if_needed()
	_commit_state()


func restart_tutorial() -> void:
	tutorial_step = 0
	tutorial_completed = false
	_commit_state()


func has_pending_story_decision() -> bool:
	return not pending_story_decision.is_empty()


func get_pending_story_decision() -> Dictionary:
	return pending_story_decision


func has_decision_feedback() -> bool:
	return not decision_feedback.is_empty()


func get_decision_feedback() -> Dictionary:
	return decision_feedback


func get_decision_history() -> Array:
	return decision_history.duplicate(true)


func get_scheduled_consequences() -> Array:
	return scheduled_consequences.duplicate(true)


func get_consequence_history() -> Array:
	return consequence_history.duplicate(true)


func dismiss_decision_feedback() -> void:
	decision_feedback = {}
	_commit_state()


func can_choose_story_option(choice_index: int) -> bool:
	if not has_pending_story_decision():
		return false
	var choices: Array = pending_story_decision.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return false
	var choice: Dictionary = choices[choice_index]
	var requirements: Dictionary = choice.get("requirements", {})
	if cash < int(requirements.get("cash", 0)):
		return false
	if savings_balance < float(requirements.get("savings", 0)):
		return false
	if debt < int(requirements.get("debt_min", 0)):
		return false
	if _get_total_owned_share_count() < int(requirements.get("shares_min", 0)):
		return false
	var stock_requirement: Dictionary = requirements.get("stock_cash", {})
	if not stock_requirement.is_empty():
		var company_id: String = str(stock_requirement.get("company_id", ""))
		var quantity: int = int(stock_requirement.get("quantity", 0))
		if quantity <= 0 or get_company_price(company_id) <= 0:
			return false
		if cash < get_company_price(company_id) * quantity:
			return false
	return true


func resolve_story_decision(choice_index: int) -> String:
	if not has_pending_story_decision():
		return "Nie ma obecnie decyzji fabularnej do podjęcia."
	if not can_choose_story_option(choice_index):
		return "Nie spełniasz warunków potrzebnych do wybrania tej opcji."
	var decision: Dictionary = pending_story_decision
	var choices: Array = decision.get("choices", [])
	var choice: Dictionary = choices[choice_index]
	_record_story_choice_risk(str(choice.get("risk", "NISKIE")))
	_apply_effects(choice.get("effects", {}))

	var outcomes: Array = choice.get("outcomes", [])
	var selected_outcome: Dictionary = {}
	if not outcomes.is_empty():
		var selected_outcome_index: int = clampi(
			int(choice.get("selected_outcome_index", 0)),
			0,
			outcomes.size() - 1
		)
		selected_outcome = outcomes[selected_outcome_index]
		_apply_effects(selected_outcome.get("effects", {}))

	var delayed_effects: Array = []
	var delayed_source: Array = choice.get("delayed_effects", [])
	if not selected_outcome.is_empty():
		delayed_source = selected_outcome.get("delayed_effects", [])
	for delayed_source_value in delayed_source:
		delayed_effects.append(delayed_source_value.duplicate(true))

	var decision_id: String = str(decision.get("id", ""))
	for delayed_index in range(delayed_effects.size()):
		var delayed_value: Dictionary = delayed_effects[delayed_index]
		var delayed_effect: Dictionary = delayed_value.duplicate(true)
		delayed_effect["due_week"] = total_weeks_passed + int(delayed_effect.get("delay_weeks", 0))
		delayed_effect["source_title"] = str(decision.get("title", "DECYZJA"))
		delayed_effect["source_choice"] = str(choice.get("title", "OPCJA"))
		delayed_effect["risk"] = str(choice.get("risk", "NISKIE"))
		delayed_effect["consequence_id"] = "%s_%d_%d_%d" % [
			decision_id,
			choice_index,
			total_weeks_passed,
			delayed_index
		]
		scheduled_consequences.append(delayed_effect)
	if not decision_id.is_empty() and not story_decision_history.has(decision_id):
		story_decision_history.append(decision_id)
	story_decisions_resolved += 1
	var visible_result: String = str(choice.get("result", "Decyzja została zapisana."))
	if bool(selected_outcome.get("reveal_immediately", false)):
		visible_result = str(selected_outcome.get("result", visible_result))
	decision_history.append({
		"decision_id": decision_id,
		"week": get_chapter_week_number(),
		"title": str(decision.get("title", "DECYZJA")),
		"choice": str(choice.get("title", "OPCJA")),
		"risk": str(choice.get("risk", "NISKIE")),
		"risk_note": str(choice.get("risk_note", "")),
		"result": visible_result,
		"education": str(choice.get("education", "")),
		"pending_consequences": delayed_effects.size()
	})
	var future_note: String = ""
	if not outcomes.is_empty() and not delayed_effects.is_empty():
		future_note = "Losowy rezultat został już ustalony i zapisany. Poznasz go w kolejnych tygodniach."
	elif delayed_effects.size() == 1:
		future_note = "Ta decyzja ma jeszcze jeden skutek, który pojawi się w kolejnych tygodniach."
	elif delayed_effects.size() > 1:
		future_note = "Ta decyzja ma dalsze skutki, które pojawią się w kolejnych tygodniach."
	decision_feedback = {
		"title": str(decision.get("title", "SKUTEK DECYZJI")),
		"result": visible_result,
		"risk": str(choice.get("risk", "NISKIE")),
		"education": str(choice.get("education", "")),
		"future_note": future_note
	}
	pending_story_decision = {}
	_commit_state()
	return str(decision_feedback.get("result", "Decyzja została zapisana."))


func _trigger_story_decision_if_needed() -> bool:
	if not tutorial_completed or chapter_finished or has_pending_story_decision() or has_decision_feedback():
		return false
	var decision: Dictionary = StoryData.get_decision_for_week(get_chapter_week_number())
	if decision.is_empty():
		return false
	var decision_id: String = str(decision.get("id", ""))
	if decision_id.is_empty() or story_decision_history.has(decision_id):
		return false
	pending_story_decision = _prepare_story_decision(decision)
	return true


func _prepare_story_decision(decision: Dictionary) -> Dictionary:
	var prepared_decision: Dictionary = decision.duplicate(true)
	if bool(prepared_decision.get("outcomes_prepared", false)):
		return prepared_decision
	var choices: Array = prepared_decision.get("choices", [])
	for choice_index in range(choices.size()):
		var choice: Dictionary = choices[choice_index]
		var outcomes: Array = choice.get("outcomes", [])
		if outcomes.is_empty():
			continue
		var total_weight: int = 0
		for outcome_value in outcomes:
			var outcome_for_weight: Dictionary = outcome_value
			total_weight += max(0, int(outcome_for_weight.get("weight", 0)))
		if total_weight <= 0:
			choice["selected_outcome_index"] = 0
			choices[choice_index] = choice
			continue
		var roll: int = randi_range(1, total_weight)
		var accumulated_weight: int = 0
		var selected_index: int = 0
		for outcome_index in range(outcomes.size()):
			var outcome_candidate: Dictionary = outcomes[outcome_index]
			accumulated_weight += max(0, int(outcome_candidate.get("weight", 0)))
			if roll <= accumulated_weight:
				selected_index = outcome_index
				break
		choice["selected_outcome_index"] = selected_index
		choices[choice_index] = choice
	prepared_decision["choices"] = choices
	prepared_decision["outcomes_prepared"] = true
	return prepared_decision


func _apply_effects(effects: Dictionary) -> void:
	var cash_change: int = int(effects.get("cash", 0))
	cash += cash_change
	if cash_change > 0:
		_add_stat("total_story_income", cash_change)
	elif cash_change < 0:
		_add_stat("total_story_spending", abs(cash_change))
	var savings_before: float = savings_balance
	var savings_change: float = float(effects.get("savings", 0))
	savings_balance = max(0.0, savings_balance + savings_change)
	var actual_savings_change: float = savings_balance - savings_before
	if actual_savings_change > 0.0:
		_add_stat("total_savings_deposited", actual_savings_change)
	elif actual_savings_change < 0.0:
		_add_stat("total_savings_withdrawn", abs(actual_savings_change))
	if savings_change >= REGULAR_SAVING_MIN_AMOUNT:
		saving_weeks[total_weeks_passed] = true
	debt = max(0, debt + int(effects.get("debt", 0)))
	monthly_income_bonus += int(effects.get("monthly_income_bonus", 0))
	monthly_expense_modifier += int(effects.get("monthly_expense_modifier", 0))
	var stock_purchase: Dictionary = effects.get("stock_purchase", {})
	if not stock_purchase.is_empty():
		_apply_stock_purchase(str(stock_purchase.get("company_id", "")), int(stock_purchase.get("quantity", 0)))
	if bool(effects.get("sell_all_stocks", false)):
		_sell_portfolio_fraction(1.0)
	if bool(effects.get("sell_half_stocks", false)):
		_sell_portfolio_fraction(0.5)
	var repayment_limit: int = int(effects.get("repay_debt", 0))
	if repayment_limit > 0:
		var repayment: int = min(repayment_limit, min(max(0, cash), debt))
		cash -= repayment
		debt -= repayment
	var mandatory_cost: int = int(effects.get("mandatory_cost", 0))
	if mandatory_cost > 0:
		_cover_mandatory_cost(mandatory_cost, false)
	var savings_cost: int = int(effects.get("savings_cost", 0))
	if savings_cost > 0:
		_cover_mandatory_cost(savings_cost, true)
	var company_price_change: Dictionary = effects.get("company_price_change", {})
	if not company_price_change.is_empty():
		_apply_company_price_change(str(company_price_change.get("company_id", "")), int(company_price_change.get("percent", 0)))
	var market_change: int = int(effects.get("all_company_change_percent", 0))
	if market_change != 0:
		for company_id_value in COMPANY_ORDER:
			_apply_company_price_change(str(company_id_value), market_change)


func _apply_stock_purchase(company_id: String, quantity: int) -> void:
	if not companies.has(company_id) or quantity <= 0:
		return
	var price: int = get_company_price(company_id)
	var total_cost: int = price * quantity
	if price <= 0 or cash < total_cost:
		return
	var company_state: Dictionary = companies[company_id]
	var old_shares: int = int(company_state.get("shares", 0))
	var old_average: float = float(company_state.get("average_buy_price", 0.0))
	var new_shares: int = old_shares + quantity
	company_state["average_buy_price"] = (old_average * old_shares + total_cost) / new_shares
	company_state["shares"] = new_shares
	companies[company_id] = company_state
	cash -= total_cost
	_add_stat("total_stock_purchases", total_cost)
	first_stock_bought = true


func _sell_portfolio_fraction(fraction: float) -> void:
	for company_id_value in COMPANY_ORDER:
		var company_id: String = str(company_id_value)
		var shares: int = get_company_shares(company_id)
		if shares <= 0:
			continue
		var quantity: int = shares
		if fraction < 1.0:
			quantity = max(1, ceili(shares * fraction))
		_sell_stock_without_commit(company_id, quantity)


func _sell_stock_without_commit(company_id: String, quantity: int) -> void:
	var shares: int = get_company_shares(company_id)
	if shares <= 0 or quantity <= 0:
		return
	quantity = min(quantity, shares)
	var price: int = get_company_price(company_id)
	var company_state: Dictionary = companies[company_id]
	var average_buy_price: float = float(company_state.get("average_buy_price", 0.0))
	var sale_value: int = price * quantity
	cash += sale_value
	_add_stat("total_stock_sales", sale_value)
	company_state["realized_profit"] = float(company_state.get("realized_profit", 0.0)) + (price - average_buy_price) * quantity
	company_state["shares"] = shares - quantity
	if int(company_state["shares"]) <= 0:
		company_state["average_buy_price"] = 0.0
	companies[company_id] = company_state


func _get_total_owned_share_count() -> int:
	var total_shares: int = 0
	for company_id_value in COMPANY_ORDER:
		total_shares += get_company_shares(str(company_id_value))
	return total_shares


func _cover_mandatory_cost(cost: int, savings_first: bool) -> void:
	var remaining_cost: int = max(0, cost)
	_add_stat("total_unplanned_costs", remaining_cost)
	if savings_first:
		var savings_payment: int = min(remaining_cost, floori(savings_balance))
		savings_balance -= savings_payment
		_add_stat("total_savings_withdrawn", savings_payment)
		remaining_cost -= savings_payment
	var cash_payment: int = min(remaining_cost, max(0, cash))
	cash -= cash_payment
	remaining_cost -= cash_payment
	if not savings_first and remaining_cost > 0:
		var second_savings_payment: int = min(remaining_cost, floori(savings_balance))
		savings_balance -= second_savings_payment
		_add_stat("total_savings_withdrawn", second_savings_payment)
		remaining_cost -= second_savings_payment
	if remaining_cost > 0:
		debt += remaining_cost


func _record_story_choice_risk(risk_value: String) -> void:
	var risk: String = risk_value.to_upper()
	if risk == "NISKIE":
		_add_stat("low_risk_decisions", 1)
	elif risk == "ŚREDNIE":
		_add_stat("medium_risk_decisions", 1)
	elif risk == "WYSOKIE":
		_add_stat("high_risk_decisions", 1)
		var liquid_assets: float = cash + savings_balance
		if liquid_assets < get_monthly_expenses() or debt > 0:
			_add_stat("unsafe_high_risk_decisions", 1)


func _apply_company_price_change(company_id: String, percent: int) -> void:
	if not companies.has(company_id) or percent == 0:
		return
	var company_state: Dictionary = companies[company_id]
	var new_price: int = calculate_new_price(int(company_state.get("price", 1)), percent)
	company_state["price"] = new_price
	company_state["last_change_percent"] = int(company_state.get("last_change_percent", 0)) + percent
	var history: Array = company_state.get("price_history", [])
	if history.is_empty():
		history.append(new_price)
	else:
		history[history.size() - 1] = new_price
	company_state["price_history"] = history
	companies[company_id] = company_state


func _process_due_consequences(target_week: int) -> Array:
	var reports: Array = []
	var remaining_consequences: Array = []
	for consequence_value in scheduled_consequences:
		var consequence: Dictionary = consequence_value
		if int(consequence.get("due_week", 0)) > target_week:
			remaining_consequences.append(consequence)
			continue
		_apply_effects(consequence.get("effects", {}))
		var consequence_report: String = str(
			consequence.get("report", "Zadziałał skutek wcześniejszej decyzji.")
		)
		reports.append(consequence_report)
		consequence_history.append({
			"consequence_id": str(consequence.get("consequence_id", "")),
			"week": target_week,
			"source_title": str(consequence.get("source_title", "DECYZJA")),
			"source_choice": str(consequence.get("source_choice", "")),
			"risk": str(consequence.get("risk", "NISKIE")),
			"report": consequence_report
		})
	scheduled_consequences = remaining_consequences
	return reports


func _initialize_companies() -> void:
	companies.clear()

	for company_id_value in COMPANY_ORDER:
		var company_id: String = str(company_id_value)
		var definition: Dictionary = COMPANY_DEFINITIONS[company_id]
		companies[company_id] = {
			"price": int(definition["start_price"]),
			"shares": 0,
			"average_buy_price": 0.0,
			"realized_profit": 0.0,
			"last_change_percent": 0,
			"price_history": [int(definition["start_price"])]
		}


func get_company_ids() -> Array:
	return COMPANY_ORDER.duplicate()


func get_company_definition(company_id: String) -> Dictionary:
	if not COMPANY_DEFINITIONS.has(company_id):
		return {}
	return COMPANY_DEFINITIONS[company_id]


func get_company_price(company_id: String) -> int:
	if not companies.has(company_id):
		return 0
	return int(companies[company_id]["price"])


func get_company_shares(company_id: String) -> int:
	if not companies.has(company_id):
		return 0
	return int(companies[company_id]["shares"])


func get_company_value(company_id: String) -> float:
	return get_company_price(company_id) * get_company_shares(company_id)


func get_company_average_buy_price(company_id: String) -> float:
	if not companies.has(company_id):
		return 0.0
	return float(companies[company_id].get("average_buy_price", 0.0))


func get_company_invested_amount(company_id: String) -> float:
	return get_company_average_buy_price(company_id) * get_company_shares(company_id)


func get_company_unrealized_profit(company_id: String) -> float:
	return get_company_value(company_id) - get_company_invested_amount(company_id)


func get_company_unrealized_percent(company_id: String) -> float:
	var invested_amount: float = get_company_invested_amount(company_id)
	if invested_amount <= 0.0:
		return 0.0
	return get_company_unrealized_profit(company_id) / invested_amount * 100.0


func get_company_realized_profit(company_id: String) -> float:
	if not companies.has(company_id):
		return 0.0
	return float(companies[company_id].get("realized_profit", 0.0))


func get_company_last_change_percent(company_id: String) -> int:
	if not companies.has(company_id):
		return 0
	return int(companies[company_id].get("last_change_percent", 0))


func get_company_price_history(company_id: String) -> Array:
	if not companies.has(company_id):
		return []
	var history: Array = companies[company_id].get("price_history", [])
	return history.duplicate()


func get_all_stock_value() -> float:
	var total: float = 0.0
	for company_id_value in COMPANY_ORDER:
		total += get_company_value(str(company_id_value))
	return total


func get_total_invested_amount() -> float:
	var total: float = 0.0
	for company_id_value in COMPANY_ORDER:
		total += get_company_invested_amount(str(company_id_value))
	return total


func get_total_unrealized_profit() -> float:
	var total: float = 0.0
	for company_id_value in COMPANY_ORDER:
		total += get_company_unrealized_profit(str(company_id_value))
	return total


func get_total_realized_profit() -> float:
	var total: float = 0.0
	for company_id_value in COMPANY_ORDER:
		total += get_company_realized_profit(str(company_id_value))
	return total


func get_owned_company_count() -> int:
	var count: int = 0
	for company_id_value in COMPANY_ORDER:
		if get_company_shares(str(company_id_value)) > 0:
			count += 1
	return count


func get_max_buyable_shares(company_id: String) -> int:
	var price: int = get_company_price(company_id)
	if price <= 0:
		return 0
	return floori(float(cash) / float(price))


func buy_stock(company_id: String, quantity: int = 1) -> String:
	if not can_make_financial_decisions():
		return "Najpierw zakończ lub rozwiąż aktualne wydarzenie."
	if not companies.has(company_id):
		return "Nieznana firma."
	if quantity <= 0:
		return "Liczba kupowanych akcji musi być większa od zera."

	var price: int = get_company_price(company_id)
	var total_cost: int = price * quantity
	var definition: Dictionary = get_company_definition(company_id)
	if cash < total_cost:
		return "Nie masz wystarczającej gotówki na zakup %d akcji." % quantity

	cash -= total_cost
	var company_state: Dictionary = companies[company_id]
	var old_shares: int = int(company_state["shares"])
	var old_average: float = float(company_state.get("average_buy_price", 0.0))
	var new_shares: int = old_shares + quantity
	company_state["average_buy_price"] = (
		(old_average * old_shares + total_cost) / new_shares
	)
	company_state["shares"] = new_shares
	companies[company_id] = company_state
	_add_stat("total_stock_purchases", total_cost)
	first_stock_bought = true
	_commit_state()

	return "Kupiono %d akcji %s za łącznie %s M$." % [
		quantity,
		str(definition["name"]),
		format_money(total_cost)
	]


func sell_stock(company_id: String, quantity: int = 1) -> String:
	if not can_make_financial_decisions():
		return "Najpierw zakończ lub rozwiąż aktualne wydarzenie."
	if not companies.has(company_id):
		return "Nieznana firma."
	if quantity <= 0:
		return "Liczba sprzedawanych akcji musi być większa od zera."

	var shares: int = get_company_shares(company_id)
	if shares < quantity:
		return "Nie masz tylu akcji. Posiadasz obecnie: %d." % shares

	var price: int = get_company_price(company_id)
	var total_value: int = price * quantity
	var definition: Dictionary = get_company_definition(company_id)
	cash += total_value

	var company_state: Dictionary = companies[company_id]
	var average_buy_price: float = float(
		company_state.get("average_buy_price", 0.0)
	)
	company_state["realized_profit"] = (
		float(company_state.get("realized_profit", 0.0))
		+ (price - average_buy_price) * quantity
	)
	company_state["shares"] = shares - quantity
	if int(company_state["shares"]) <= 0:
		company_state["average_buy_price"] = 0.0
	companies[company_id] = company_state
	_add_stat("total_stock_sales", total_value)
	_commit_state()

	return "Sprzedano %d akcji %s za łącznie %s M$." % [
		quantity,
		str(definition["name"]),
		format_money(total_value)
	]


func deposit_savings(amount: int = SAVINGS_DEFAULT_AMOUNT) -> String:
	if not can_make_financial_decisions():
		return "Najpierw zakończ lub rozwiąż aktualne wydarzenie."
	if amount < SAVINGS_MIN_AMOUNT:
		return "Minimalna wpłata wynosi %s M$." % format_money(SAVINGS_MIN_AMOUNT)
	if cash < amount:
		return "Nie masz wystarczającej gotówki, aby wpłacić %s M$." % format_money(amount)

	cash -= amount
	savings_balance += amount
	_add_stat("total_savings_deposited", amount)
	if amount >= REGULAR_SAVING_MIN_AMOUNT:
		saving_weeks[total_weeks_passed] = true
	_commit_state()

	if amount < REGULAR_SAVING_MIN_AMOUNT:
		return (
			"Wpłacono %s M$. Wpłata jest mniejsza niż %s M$, więc nie liczy się "
			+ "do celu regularnego oszczędzania."
		) % [format_money(amount), format_money(REGULAR_SAVING_MIN_AMOUNT)]
	return "Wpłacono %s M$. Ten tydzień liczy się do celu regularności." % format_money(amount)


func withdraw_savings(amount: int = SAVINGS_DEFAULT_AMOUNT) -> String:
	if not can_make_financial_decisions():
		return "Najpierw zakończ lub rozwiąż aktualne wydarzenie."
	if amount < SAVINGS_MIN_AMOUNT:
		return "Minimalna wypłata wynosi %s M$." % format_money(SAVINGS_MIN_AMOUNT)
	if savings_balance < amount:
		return "Na koncie oszczędnościowym nie ma wystarczających środków."

	savings_balance -= amount
	cash += amount
	_add_stat("total_savings_withdrawn", amount)
	_commit_state()
	return "Wypłacono %s M$ z konta oszczędnościowego." % format_money(amount)


func repay_debt() -> String:
	if not can_make_financial_decisions():
		return "Najpierw zakończ lub rozwiąż aktualne wydarzenie."
	if debt <= 0:
		return "Nie masz obecnie żadnego długu."
	if cash <= 0:
		return "Nie masz gotówki potrzebnej do spłaty długu."

	var payment: int = min(DEBT_REPAY_AMOUNT, min(cash, debt))
	cash -= payment
	debt -= payment
	_commit_state()

	if debt <= 0:
		return "Nadpłacono %s M$. Dług został całkowicie spłacony." % format_money(payment)
	return "Nadpłacono %s M$. Pozostały dług: %s M$." % [format_money(payment), format_money(debt)]


func can_take_player_loan() -> bool:
	return (
		can_make_financial_decisions()
		and debt <= 0
		and voluntary_loans_taken < MAX_VOLUNTARY_LOANS
	)


func take_player_loan() -> String:
	if not can_make_financial_decisions():
		return "Pożyczki nie można teraz uruchomić."
	if debt > 0:
		return "Najpierw spłać obecny dług."
	if voluntary_loans_taken >= MAX_VOLUNTARY_LOANS:
		return "W tym rozdziale wykorzystano już dobrowolną pożyczkę."

	cash += PLAYER_LOAN_AMOUNT
	debt += PLAYER_LOAN_AMOUNT
	voluntary_loans_taken += 1
	_commit_state()

	return (
		"Otrzymano %s M$ pożyczki. Pierwsza rata zostanie pobrana "
		+ "przy zakończeniu tygodnia."
	) % format_money(PLAYER_LOAN_AMOUNT)


func get_next_loan_interest() -> int:
	if debt <= 0:
		return 0
	return max(1, roundi(debt * LOAN_WEEKLY_RATE))


func get_next_loan_payment() -> int:
	if debt <= 0:
		return 0
	return min(LOAN_WEEKLY_PRINCIPAL, debt) + get_next_loan_interest()


func get_estimated_loan_weeks() -> int:
	if debt <= 0:
		return 0
	return ceili(float(debt) / LOAN_WEEKLY_PRINCIPAL)


func _process_weekly_loan_payment() -> Dictionary:
	if debt <= 0:
		return {}

	var opening_debt: int = debt
	var interest_due: int = get_next_loan_interest()
	var principal_due: int = min(LOAN_WEEKLY_PRINCIPAL, opening_debt)
	var scheduled_payment: int = principal_due + interest_due
	var actual_payment: int = min(max(0, cash), scheduled_payment)
	var interest_paid: int = min(actual_payment, interest_due)
	var unpaid_interest: int = interest_due - interest_paid
	var principal_paid: int = min(
		opening_debt,
		max(0, actual_payment - interest_paid)
	)

	cash -= actual_payment
	debt = opening_debt - principal_paid + unpaid_interest
	total_loan_interest_charged += interest_due

	var payment_missed: bool = actual_payment < scheduled_payment
	if payment_missed:
		missed_loan_payments += 1
	else:
		loan_payments_made += 1

	var report: String = (
		"Rata pożyczki: -%s M$ (kapitał %s M$, odsetki %s M$). "
		+ "Pozostały dług: %s M$."
	) % [
		format_money(actual_payment),
		format_money(principal_paid),
		format_money(interest_paid),
		format_money(debt)
	]

	if payment_missed:
		report += " Brakowało %s M$ do pełnej raty." % (
			format_money(scheduled_payment - actual_payment)
		)
		if unpaid_interest > 0:
			report += " Niezapłacone odsetki zostały dodane do długu."
		else:
			report += " Odsetki zapłacono, ale nie spłacono całej części kapitałowej."
	elif debt <= 0:
		report += " Pożyczka została całkowicie spłacona."

	return {
		"opening_debt": opening_debt,
		"interest": interest_due,
		"scheduled_payment": scheduled_payment,
		"actual_payment": actual_payment,
		"principal_paid": principal_paid,
		"remaining_debt": debt,
		"missed": payment_missed,
		"report": report
	}


func end_week() -> String:
	if chapter_finished:
		return "Pierwszy rozdział został już zakończony."
	if has_pending_story_decision():
		return "Najpierw podejmij decyzję fabularną na ten tydzień."
	if has_decision_feedback():
		return "Najpierw przeczytaj skutek ostatniej decyzji."
	if has_pending_life_event():
		return "Najpierw musisz podjąć decyzję dotyczącą wydarzenia."
	if not tutorial_completed:
		return "Najpierw ukończ albo pomiń samouczek."

	var opening_prices: Dictionary = {}
	for opening_company_id_value in COMPANY_ORDER:
		var opening_company_id: String = str(opening_company_id_value)
		opening_prices[opening_company_id] = get_company_price(opening_company_id)
	var consequence_reports: Array = _process_due_consequences(total_weeks_passed + 1)
	var event: Dictionary = get_current_market_event()
	var changes: Dictionary = event["changes"]
	var total_investment_result: int = 0
	var company_lines: PackedStringArray = []
	var company_results: Array = []

	for company_id_value in COMPANY_ORDER:
		var company_id: String = str(company_id_value)
		var definition: Dictionary = get_company_definition(company_id)
		var old_price: int = int(opening_prices[company_id])
		var price_before_market: int = get_company_price(company_id)
		var market_change_percent: int = int(changes.get(company_id, 0))
		var new_price: int = calculate_new_price(price_before_market, market_change_percent)
		var displayed_change_percent: int = roundi((float(new_price - old_price) / float(old_price)) * 100.0)
		var shares: int = get_company_shares(company_id)

		var company_state: Dictionary = companies[company_id]
		company_state["price"] = new_price
		company_state["last_change_percent"] = displayed_change_percent
		var price_history: Array = company_state.get("price_history", [])
		price_history.append(new_price)
		while price_history.size() > 12:
			price_history.pop_front()
		company_state["price_history"] = price_history
		companies[company_id] = company_state
		var position_result: int = shares * (new_price - old_price)
		total_investment_result += position_result

		company_results.append({
			"company_id": company_id,
			"name": str(definition["name"]),
			"ticker": str(definition["ticker"]),
			"old_price": old_price,
			"new_price": new_price,
			"change_percent": displayed_change_percent,
			"shares": shares,
			"position_result": position_result
		})

		company_lines.append("%s: %s → %s M$ (%s%%)" % [
			str(definition["ticker"]),
			format_money(old_price),
			format_money(new_price),
			format_signed_number(displayed_change_percent)
		])

	var monthly_report: String = advance_time()
	var loan_payment: Dictionary = _process_weekly_loan_payment()
	_record_completed_week_statistics()
	var loan_report: String = str(loan_payment.get("report", ""))
	var report: String = (
		"RYNEK: %s\n" % str(event["headline"])
		+ "\n".join(company_lines)
		+ "\nWpływ akcji na majątek: %s M$.\n\n" % format_signed_money(total_investment_result)
		+ "Dlaczego? %s" % str(event["explanation"])
		+ monthly_report
	)
	if not loan_report.is_empty():
		report += "\n\n" + loan_report
	if not consequence_reports.is_empty():
		report += "\n\nKONSEKWENCJE WCZEŚNIEJSZYCH DECYZJI:\n"
		report += "\n".join(PackedStringArray(consequence_reports))

	last_week_summary = {
		"completed_week": total_weeks_passed,
		"headline": str(event["headline"]),
		"explanation": str(event["explanation"]),
		"companies": company_results,
		"portfolio_change": total_investment_result,
		"monthly_report": monthly_report.strip_edges(),
		"loan_report": loan_report,
		"loan_missed": bool(loan_payment.get("missed", false)),
		"consequence_reports": consequence_reports,
		"cash_after": cash,
		"net_worth_after": get_net_worth()
	}

	_choose_next_market_event()
	if total_weeks_passed >= CHAPTER_LENGTH_WEEKS:
		chapter_finished = true
		report += "\n\nRozdział 1 został zakończony. Sprawdź podsumowanie."
	else:
		var story_decision_started: bool = _trigger_story_decision_if_needed()
		if story_decision_started:
			report += "\n\nRozpoczyna się nowa sytuacja fabularna. Po podsumowaniu tygodnia wybierz dalsze działanie."
		else:
			var life_event_started: bool = _trigger_life_event_if_needed()
			if life_event_started:
				report += "\n\nPojawiło się wydarzenie życiowe. Musisz zdecydować, jak pokryjesz jego koszt."

	_commit_state()
	return report


func resolve_life_event(payment_method: String) -> String:
	if not has_pending_life_event():
		return "Nie ma obecnie żadnego wydarzenia do rozwiązania."

	var event: Dictionary = pending_life_event
	var cost: int = int(event["cost"])
	var payment_report: String = ""

	match payment_method:
		"cash":
			if cash < cost:
				return "Nie masz wystarczającej ilości gotówki."
			cash -= cost
			_add_stat("life_events_paid_cash", 1)
			payment_report = "Zapłacono %s M$ gotówką. Nie powstał dług, ale zmniejszyła się płynność." % format_money(cost)

		"savings":
			if savings_balance < cost:
				return "Nie masz wystarczających środków na koncie oszczędnościowym."
			savings_balance -= cost
			_add_stat("life_events_paid_savings", 1)
			_add_stat("total_savings_withdrawn", cost)
			payment_report = "Zapłacono %s M$ z oszczędności. Poduszka bezpieczeństwa spełniła swoje zadanie." % format_money(cost)

		"loan":
			debt += cost
			_add_stat("life_events_financed_by_loan", 1)
			payment_report = (
				"Koszt pokryto pożyczką. Dług wzrósł o %s M$. "
				+ "Rata i tygodniowe odsetki zostaną naliczone przy "
				+ "zakończeniu kolejnego tygodnia."
			) % format_money(cost)

		_:
			return "Nieznany sposób rozwiązania wydarzenia."

	_add_stat("life_event_costs_total", cost)

	var income_bonus: int = int(event.get("income_bonus", 0))
	if income_bonus > 0:
		monthly_income_bonus += income_bonus
		payment_report += "\nUkończenie kursu zwiększa miesięczny dochód o %s M$." % format_money(income_bonus)

	pending_life_event = {}
	life_events_resolved += 1
	next_life_event_week = total_weeks_passed + randi_range(6, 8)
	_commit_state()
	return payment_report


func _trigger_life_event_if_needed() -> bool:
	if has_pending_life_event() or total_weeks_passed < next_life_event_week:
		return false

	var available_indices: Array = []
	for index in range(LIFE_EVENTS.size()):
		if index != last_life_event_index and not used_life_event_indices.has(index):
			available_indices.append(index)

	if available_indices.is_empty():
		used_life_event_indices.clear()
		for index in range(LIFE_EVENTS.size()):
			if index != last_life_event_index:
				available_indices.append(index)

	var selected_position: int = randi_range(0, available_indices.size() - 1)
	var selected_index: int = int(available_indices[selected_position])
	last_life_event_index = selected_index
	used_life_event_indices.append(selected_index)
	pending_life_event = LIFE_EVENTS[selected_index].duplicate(true)
	return true


func _choose_next_market_event() -> void:
	if MARKET_EVENTS.is_empty():
		current_market_event_index = -1
		return

	var next_index: int = randi_range(0, MARKET_EVENTS.size() - 1)
	if MARKET_EVENTS.size() > 1 and next_index == current_market_event_index:
		next_index = (next_index + randi_range(1, MARKET_EVENTS.size() - 1)) % MARKET_EVENTS.size()
	current_market_event_index = next_index


func get_current_market_event() -> Dictionary:
	if current_market_event_index < 0:
		_choose_next_market_event()
	return MARKET_EVENTS[current_market_event_index]


func has_pending_life_event() -> bool:
	return not pending_life_event.is_empty()


func get_pending_life_event() -> Dictionary:
	return pending_life_event


func can_make_financial_decisions() -> bool:
	return (
		tutorial_completed
		and not chapter_finished
		and not has_pending_life_event()
		and not has_pending_story_decision()
		and not has_decision_feedback()
	)


func get_monthly_income() -> int:
	return MONTHLY_INCOME + monthly_income_bonus


func get_monthly_expenses() -> int:
	return max(1, MONTHLY_EXPENSES + monthly_expense_modifier)


func get_net_worth() -> float:
	return cash + savings_balance + get_all_stock_value() - debt


func get_regular_saving_week_count() -> int:
	return saving_weeks.size()


func get_chapter_week_number() -> int:
	if chapter_finished:
		return CHAPTER_LENGTH_WEEKS
	return min(total_weeks_passed + 1, CHAPTER_LENGTH_WEEKS)


func get_goal_statuses() -> Array:
	var saving_week_count: int = get_regular_saving_week_count()
	var owned_company_count: int = get_owned_company_count()
	var debt_goal_done: bool = life_events_resolved >= REQUIRED_LIFE_EVENTS and debt <= 500

	return [
		{"title": "Wpłacaj na oszczędności w 12 różnych tygodniach", "progress": "%d/%d" % [saving_week_count, REQUIRED_SAVING_WEEKS], "done": saving_week_count >= REQUIRED_SAVING_WEEKS},
		{"title": "Kup swoją pierwszą akcję", "progress": "", "done": first_stock_bought},
		{"title": "Posiadaj akcje przynajmniej 3 firm", "progress": "%d/%d" % [owned_company_count, REQUIRED_COMPANIES], "done": owned_company_count >= REQUIRED_COMPANIES},
		{"title": "Zbuduj poduszkę bezpieczeństwa 5 400 M$", "progress": "%s/%s M$" % [format_money_decimal(savings_balance), format_money(EMERGENCY_FUND_TARGET)], "done": savings_balance >= EMERGENCY_FUND_TARGET},
		{"title": "Rozwiąż przynajmniej 4 wydarzenia życiowe", "progress": "%d/%d" % [min(life_events_resolved, REQUIRED_LIFE_EVENTS), REQUIRED_LIFE_EVENTS], "done": life_events_resolved >= REQUIRED_LIFE_EVENTS},
		{"title": "Po wydarzeniach utrzymaj dług na poziomie maks. 500 M$", "progress": "%s M$" % format_money(debt), "done": debt_goal_done}
	]


func get_completed_goal_count() -> int:
	var completed: int = 0
	for goal_value in get_goal_statuses():
		var goal: Dictionary = goal_value
		if bool(goal["done"]):
			completed += 1
	return completed


func _score_grade(score: int) -> String:
	if score >= 90:
		return "S"
	if score >= 80:
		return "A"
	if score >= 65:
		return "B"
	if score >= 50:
		return "C"
	return "D"


func _evaluation_category(
	name: String,
	score_value: float,
	comment: String
) -> Dictionary:
	var score: int = clampi(roundi(score_value), 0, 100)
	return {
		"name": name,
		"score": score,
		"grade": _score_grade(score),
		"comment": comment
	}


func get_chapter_evaluation() -> Dictionary:
	_update_stat_extremes()
	var liquid_assets: float = cash + savings_balance
	var monthly_expenses: float = get_monthly_expenses()
	var emergency_ratio: float = savings_balance / float(EMERGENCY_FUND_TARGET)
	var liquid_months: float = liquid_assets / monthly_expenses
	var emergency_score: float = (
		clampf(emergency_ratio, 0.0, 1.0) * 70.0
		+ clampf(liquid_months / 3.0, 0.0, 1.0) * 30.0
	)
	var emergency_comment: String = "Poduszka pokrywa co najmniej trzy miesiące wydatków."
	if emergency_score < 65.0:
		emergency_comment = "Poduszka jest zbyt mała, aby spokojnie pokrywać większe niespodziewane koszty."
	elif emergency_score < 90.0:
		emergency_comment = "Masz zabezpieczenie, ale do pełnych trzech miesięcy wydatków jeszcze trochę brakuje."

	var regular_score: float = clampf(
		float(get_regular_saving_week_count()) / float(REQUIRED_SAVING_WEEKS),
		0.0,
		1.0
	) * 100.0
	var regular_comment: String = "Oszczędzałeś w co najmniej 12 różnych tygodniach."
	if regular_score < 65.0:
		regular_comment = "Wpłaty były zbyt rzadkie. Regularność jest ważniejsza niż jedna duża wpłata na końcu."
	elif regular_score < 90.0:
		regular_comment = "Oszczędzałeś kilka razy, ale nawyk nie był jeszcze wystarczająco regularny."

	var debt_score: float = 100.0
	debt_score -= min(55.0, float(debt) / monthly_expenses * 25.0)
	debt_score -= min(36.0, float(missed_loan_payments) * 12.0)
	debt_score -= min(15.0, float(total_loan_interest_charged) / float(max(1, get_monthly_income())) * 40.0)
	debt_score -= min(15.0, float(chapter_stats.get("life_events_financed_by_loan", 0)) * 5.0)
	var debt_comment: String = "Dług jest pod kontrolą, a raty nie zagroziły budżetowi."
	if debt_score < 65.0:
		debt_comment = "Dług, odsetki lub brakujące raty mocno obciążyły wynik. Pożyczka powinna być planem awaryjnym."
	elif debt_score < 90.0:
		debt_comment = "Pożyczka pomogła w płynności, ale jej koszt obniżył ocenę zarządzania długiem."

	var recorded_weeks: int = max(1, int(chapter_stats.get("weeks_recorded", 0)))
	var safe_ratio: float = float(chapter_stats.get("safe_liquidity_weeks", 0)) / float(recorded_weeks)
	var critical_ratio: float = float(chapter_stats.get("critical_liquidity_weeks", 0)) / float(recorded_weeks)
	var liquidity_score: float = (
		clampf(safe_ratio, 0.0, 1.0) * 55.0
		+ clampf(liquid_months / 2.0, 0.0, 1.0) * 30.0
		+ (1.0 - clampf(critical_ratio, 0.0, 1.0)) * 15.0
	)
	var liquidity_comment: String = "Przez większość roku zachowałeś środki dostępne na bieżące potrzeby."
	if liquidity_score < 65.0:
		liquidity_comment = "Zbyt często brakowało łatwo dostępnych pieniędzy. Nie inwestuj całej gotówki naraz."
	elif liquidity_score < 90.0:
		liquidity_comment = "Płynność była zwykle wystarczająca, lecz pojawiały się tygodnie z małym marginesem bezpieczeństwa."

	var max_companies: int = int(chapter_stats.get("maximum_owned_companies", get_owned_company_count()))
	var investment_score: float = 20.0
	var total_trading: int = int(chapter_stats.get("total_stock_purchases", 0))
	if first_stock_bought or total_trading > 0:
		var diversification_points: float = clampf(float(max_companies) / float(REQUIRED_COMPANIES), 0.0, 1.0) * 50.0
		var investable_assets: float = max(1.0, liquid_assets + get_all_stock_value())
		var stock_share: float = get_all_stock_value() / investable_assets
		var allocation_points: float = 25.0
		if stock_share > 0.85:
			allocation_points = 8.0
		elif stock_share > 0.65:
			allocation_points = 18.0
		investment_score = 25.0 + diversification_points + allocation_points
	var investment_comment: String = "Portfel był zdywersyfikowany, a inwestycje nie wyparły całej poduszki."
	if investment_score < 65.0:
		investment_comment = "Pominąłeś inwestowanie albo portfel był zbyt skupiony w jednym miejscu."
	elif investment_score < 90.0:
		investment_comment = "Masz doświadczenie z akcjami, ale dywersyfikacja lub udział inwestycji w majątku wymaga poprawy."

	var total_risk_choices: int = (
		int(chapter_stats.get("low_risk_decisions", 0))
		+ int(chapter_stats.get("medium_risk_decisions", 0))
		+ int(chapter_stats.get("high_risk_decisions", 0))
	)
	var decision_score: float = 60.0
	if total_risk_choices > 0:
		decision_score = 70.0 + min(20.0, float(total_risk_choices) * 2.0)
		decision_score += min(10.0, float(chapter_stats.get("low_risk_decisions", 0)))
		decision_score -= float(chapter_stats.get("unsafe_high_risk_decisions", 0)) * 14.0
		decision_score -= float(chapter_stats.get("life_events_financed_by_loan", 0)) * 6.0
	var decision_comment: String = "Podejmowałeś decyzje adekwatne do swojej sytuacji, niezależnie od losowych rezultatów."
	if decision_score < 65.0:
		decision_comment = "Kilka ryzykownych decyzji podjąłeś bez wystarczającej poduszki albo przy aktywnym długu."
	elif decision_score < 90.0:
		decision_comment = "Większość wyborów była rozsądna, ale niektóre ryzyka nie pasowały do aktualnej sytuacji."

	var categories: Array = [
		_evaluation_category("Poduszka bezpieczeństwa", emergency_score, emergency_comment),
		_evaluation_category("Regularne oszczędzanie", regular_score, regular_comment),
		_evaluation_category("Zarządzanie długiem", debt_score, debt_comment),
		_evaluation_category("Płynność finansowa", liquidity_score, liquidity_comment),
		_evaluation_category("Inwestowanie i dywersyfikacja", investment_score, investment_comment),
		_evaluation_category("Jakość decyzji", decision_score, decision_comment)
	]
	var score_sum: int = 0
	var strengths: PackedStringArray = []
	var improvements: PackedStringArray = []
	for category_value in categories:
		var category: Dictionary = category_value
		var category_score: int = int(category["score"])
		score_sum += category_score
		if category_score >= 80:
			strengths.append(str(category["name"]))
		elif category_score < 65:
			improvements.append(str(category["name"]))
	var overall_score: int = roundi(float(score_sum) / float(categories.size()))
	return {
		"score": overall_score,
		"grade": _score_grade(overall_score),
		"categories": categories,
		"strengths": strengths,
		"improvements": improvements
	}


func get_chapter_summary() -> String:
	var evaluation: Dictionary = get_chapter_evaluation()
	var category_lines: PackedStringArray = []
	for category_value in evaluation["categories"]:
		var category: Dictionary = category_value
		category_lines.append("%s — %s (%d/100)\n%s" % [
			str(category["name"]),
			str(category["grade"]),
			int(category["score"]),
			str(category["comment"])
		])

	var strengths: PackedStringArray = evaluation["strengths"]
	var improvements: PackedStringArray = evaluation["improvements"]
	var strength_text: String = ", ".join(strengths) if not strengths.is_empty() else "Najpierw zbuduj stabilne podstawy — każdy wynik można poprawić w kolejnej próbie."
	var improvement_text: String = ", ".join(improvements) if not improvements.is_empty() else "Brak słabych kategorii. Spróbuj utrzymać ten wynik przy innych zdarzeniach."
	var tracking_start: int = int(chapter_stats.get("tracking_started_week", 0))
	var migration_note: String = ""
	if tracking_start > 0:
		migration_note = "\nUwaga: szczegółowe statystyki zaczęto zbierać od tygodnia %d po aktualizacji zapisu.\n" % (tracking_start + 1)

	return (
		"OCENA KOŃCOWA: %s • %d/100\n\n" % [str(evaluation["grade"]), int(evaluation["score"])]
		+ "OCENY W SZEŚCIU OBSZARACH\n\n"
		+ "\n\n".join(category_lines)
		+ "\n\nSTATYSTYKI ROKU\n"
		+ "Majątek netto: %s M$\n" % format_money_decimal(get_net_worth())
		+ "Dochody / stałe wydatki: %s / %s M$\n" % [format_money(int(chapter_stats.get("total_income_received", 0))), format_money(int(chapter_stats.get("total_expenses_paid", 0)))]
		+ "Wpłaty / wypłaty oszczędności: %s / %s M$\n" % [format_money_decimal(float(chapter_stats.get("total_savings_deposited", 0.0))), format_money_decimal(float(chapter_stats.get("total_savings_withdrawn", 0.0)))]
		+ "Najniższa płynność: %s M$ • najwyższy dług: %s M$\n" % [format_money_decimal(float(chapter_stats.get("minimum_liquid_assets", 0.0))), format_money(int(chapter_stats.get("peak_debt", 0)))]
		+ "Odsetki od długu: %s M$ • odsetki z oszczędności: %s M$\n" % [format_money(total_loan_interest_charged), format_money_decimal(float(chapter_stats.get("total_savings_interest", 0.0)))]
		+ "Wydarzenia opłacone gotówką / oszczędnościami / długiem: %d / %d / %d\n" % [int(chapter_stats.get("life_events_paid_cash", 0)), int(chapter_stats.get("life_events_paid_savings", 0)), int(chapter_stats.get("life_events_financed_by_loan", 0))]
		+ "Decyzje niskiego / średniego / wysokiego ryzyka: %d / %d / %d\n" % [int(chapter_stats.get("low_risk_decisions", 0)), int(chapter_stats.get("medium_risk_decisions", 0)), int(chapter_stats.get("high_risk_decisions", 0))]
		+ migration_note
		+ "\nCO POSZŁO DOBRZE\n" + strength_text
		+ "\n\nCO WARTO POPRAWIĆ\n" + improvement_text
		+ "\n\nLEKCJA\nDobry losowy wynik nie zawsze oznacza dobrą decyzję, a strata nie zawsze oznacza błąd. Gra ocenia przede wszystkim ryzyko podjęte przy Twojej płynności, długu i poduszce bezpieczeństwa."
	)


func calculate_new_price(price: int, change_percent: int) -> int:
	return max(1, roundi(price * (1.0 + change_percent / 100.0)))


func advance_time() -> String:
	current_week += 1
	total_weeks_passed += 1
	if current_week <= 4:
		return ""

	current_week = 1
	current_month += 1

	var savings_interest: float = savings_balance * SAVINGS_MONTHLY_RATE
	savings_balance += savings_interest
	_add_stat("total_savings_interest", savings_interest)

	var current_income: int = get_monthly_income()
	var current_expenses: int = get_monthly_expenses()
	cash += current_income
	cash -= current_expenses
	_add_stat("total_income_received", current_income)
	_add_stat("total_expenses_paid", current_expenses)

	if current_month > 12:
		current_month = 1
		current_year += 1

	var report: String = (
		"\n\nROZLICZENIE MIESIĄCA:"
		+ "\nDochód: +%s M$" % format_money(current_income)
		+ "\nWydatki: -%s M$" % format_money(current_expenses)
		+ "\nOdsetki z oszczędności: +%s M$" % format_money_decimal(savings_interest)
	)
	return report


func format_signed_number(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)


func format_signed_money(value: int) -> String:
	if value > 0:
		return "+" + format_money(value)
	return format_money(value)


func format_money_decimal(value: float) -> String:
	var total_cents: int = roundi(abs(value) * 100.0)
	var whole_part: int = int(total_cents / 100.0)
	var decimal_part: int = total_cents % 100
	var result: String = "%s,%02d" % [format_money(whole_part), decimal_part]
	if value < 0:
		result = "-" + result
	return result


func format_money(value: int) -> String:
	var number_text: String = str(abs(value))
	var result: String = ""
	while number_text.length() > 3:
		result = " " + number_text.right(3) + result
		number_text = number_text.left(number_text.length() - 3)
	result = number_text + result
	if value < 0:
		result = "-" + result
	return result
