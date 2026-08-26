extends Node


signal state_changed


const SAVE_PATH: String = "user://meow_street_save.json"
const SAVE_VERSION: int = 4

const STARTING_CASH: int = 2500
const CHAPTER_LENGTH_WEEKS: int = 12

const MONTHLY_INCOME: int = 2500
const MONTHLY_EXPENSES: int = 1800

const SAVINGS_DEFAULT_AMOUNT: int = 500
const SAVINGS_MIN_AMOUNT: int = 50
const REGULAR_SAVING_MIN_AMOUNT: int = 100
const SAVINGS_MONTHLY_RATE: float = 0.005
const EMERGENCY_FUND_TARGET: int = 5400
const REQUIRED_SAVING_WEEKS: int = 3
const REQUIRED_COMPANIES: int = 3

const DEBT_REPAY_AMOUNT: int = 500
const PLAYER_LOAN_AMOUNT: int = 2000
const LOAN_WEEKLY_PRINCIPAL: int = 250
const LOAN_WEEKLY_RATE: float = 0.01
const MAX_VOLUNTARY_LOANS: int = 1


const MarketData = preload("res://scripts/market_data.gd")

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

var saving_weeks: Dictionary = {}
var first_stock_bought: bool = false
var chapter_finished: bool = false
var tutorial_step: int = 0
var tutorial_completed: bool = false
var last_week_summary: Dictionary = {}


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
	voluntary_loans_taken = 0
	loan_payments_made = 0
	missed_loan_payments = 0
	total_loan_interest_charged = 0

	_initialize_companies()
	current_market_event_index = -1
	_choose_next_market_event()

	pending_life_event = {}
	next_life_event_week = randi_range(3, 4)
	last_life_event_index = -1
	used_life_event_indices.clear()
	life_events_resolved = 0

	saving_weeks.clear()
	first_stock_bought = false
	chapter_finished = false
	tutorial_step = 0
	tutorial_completed = false
	last_week_summary = {}

	if save_after_reset:
		save_game()

	if emit_update:
		state_changed.emit()


func start_new_game() -> void:
	reset_game(true, true)


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
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
		"saving_week_numbers": saving_week_numbers,
		"first_stock_bought": first_stock_bought,
		"chapter_finished": chapter_finished,
		"tutorial_step": tutorial_step,
		"tutorial_completed": tutorial_completed
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

	saving_weeks.clear()
	var saved_saving_weeks: Array = save_data.get("saving_week_numbers", [])

	for week_value in saved_saving_weeks:
		saving_weeks[int(week_value)] = true

	first_stock_bought = bool(save_data.get("first_stock_bought", false))
	chapter_finished = bool(save_data.get("chapter_finished", false))
	tutorial_step = max(0, int(save_data.get("tutorial_step", 0)))
	tutorial_completed = bool(save_data.get("tutorial_completed", false))


func _commit_state() -> void:
	save_game()
	state_changed.emit()


func is_tutorial_active() -> bool:
	return not tutorial_completed


func set_tutorial_step(step: int, step_count: int) -> void:
	if step_count <= 0:
		return

	tutorial_step = clampi(step, 0, step_count - 1)
	_commit_state()


func complete_tutorial() -> void:
	tutorial_completed = true
	_commit_state()


func restart_tutorial() -> void:
	tutorial_step = 0
	tutorial_completed = false
	_commit_state()


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
	var actual_payment: int = min(cash, scheduled_payment)
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
	if has_pending_life_event():
		return "Najpierw musisz podjąć decyzję dotyczącą wydarzenia."
	if not tutorial_completed:
		return "Najpierw ukończ albo pomiń samouczek."

	var event: Dictionary = get_current_market_event()
	var changes: Dictionary = event["changes"]
	var total_investment_result: int = 0
	var company_lines: PackedStringArray = []
	var company_results: Array = []

	for company_id_value in COMPANY_ORDER:
		var company_id: String = str(company_id_value)
		var definition: Dictionary = get_company_definition(company_id)
		var old_price: int = get_company_price(company_id)
		var change_percent: int = int(changes.get(company_id, 0))
		var new_price: int = calculate_new_price(old_price, change_percent)
		var shares: int = get_company_shares(company_id)

		var company_state: Dictionary = companies[company_id]
		company_state["price"] = new_price
		company_state["last_change_percent"] = change_percent
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
			"change_percent": change_percent,
			"shares": shares,
			"position_result": position_result
		})

		company_lines.append("%s: %s → %s M$ (%s%%)" % [
			str(definition["ticker"]),
			format_money(old_price),
			format_money(new_price),
			format_signed_number(change_percent)
		])

	var monthly_report: String = advance_time()
	var loan_payment: Dictionary = _process_weekly_loan_payment()
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

	last_week_summary = {
		"completed_week": total_weeks_passed,
		"headline": str(event["headline"]),
		"explanation": str(event["explanation"]),
		"companies": company_results,
		"portfolio_change": total_investment_result,
		"monthly_report": monthly_report.strip_edges(),
		"loan_report": loan_report,
		"loan_missed": bool(loan_payment.get("missed", false)),
		"cash_after": cash,
		"net_worth_after": get_net_worth()
	}

	_choose_next_market_event()
	if total_weeks_passed >= CHAPTER_LENGTH_WEEKS:
		chapter_finished = true
		report += "\n\nRozdział 1 został zakończony. Sprawdź podsumowanie."
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
			payment_report = "Zapłacono %s M$ gotówką. Nie powstał dług, ale zmniejszyła się płynność." % format_money(cost)

		"savings":
			if savings_balance < cost:
				return "Nie masz wystarczających środków na koncie oszczędnościowym."
			savings_balance -= cost
			payment_report = "Zapłacono %s M$ z oszczędności. Poduszka bezpieczeństwa spełniła swoje zadanie." % format_money(cost)

		"loan":
			debt += cost
			payment_report = (
				"Koszt pokryto pożyczką. Dług wzrósł o %s M$. "
				+ "Rata i tygodniowe odsetki zostaną naliczone przy "
				+ "zakończeniu kolejnego tygodnia."
			) % format_money(cost)

		_:
			return "Nieznany sposób rozwiązania wydarzenia."

	var income_bonus: int = int(event.get("income_bonus", 0))
	if income_bonus > 0:
		monthly_income_bonus += income_bonus
		payment_report += "\nUkończenie kursu zwiększa miesięczny dochód o %s M$." % format_money(income_bonus)

	pending_life_event = {}
	life_events_resolved += 1
	next_life_event_week = total_weeks_passed + randi_range(3, 4)
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
	)


func get_monthly_income() -> int:
	return MONTHLY_INCOME + monthly_income_bonus


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
	var debt_goal_done: bool = life_events_resolved > 0 and debt <= 500

	return [
		{"title": "Wpłacaj na oszczędności w 3 różnych tygodniach", "progress": "%d/%d" % [saving_week_count, REQUIRED_SAVING_WEEKS], "done": saving_week_count >= REQUIRED_SAVING_WEEKS},
		{"title": "Kup swoją pierwszą akcję", "progress": "", "done": first_stock_bought},
		{"title": "Posiadaj akcje przynajmniej 3 firm", "progress": "%d/%d" % [owned_company_count, REQUIRED_COMPANIES], "done": owned_company_count >= REQUIRED_COMPANIES},
		{"title": "Zbuduj poduszkę bezpieczeństwa 5 400 M$", "progress": "%s/%s M$" % [format_money_decimal(savings_balance), format_money(EMERGENCY_FUND_TARGET)], "done": savings_balance >= EMERGENCY_FUND_TARGET},
		{"title": "Rozwiąż przynajmniej 1 wydarzenie życiowe", "progress": "%d/1" % min(life_events_resolved, 1), "done": life_events_resolved >= 1},
		{"title": "Po wydarzeniu utrzymaj dług na poziomie maks. 500 M$", "progress": "%s M$" % format_money(debt), "done": debt_goal_done}
	]


func get_completed_goal_count() -> int:
	var completed: int = 0
	for goal_value in get_goal_statuses():
		var goal: Dictionary = goal_value
		if bool(goal["done"]):
			completed += 1
	return completed


func get_chapter_summary() -> String:
	var completed: int = get_completed_goal_count()
	var total_goals: int = get_goal_statuses().size()
	var assessment: String = ""

	if completed >= total_goals:
		assessment = "Świetny wynik. Połączyłeś oszczędzanie, inwestowanie i kontrolę długu."
	elif completed >= 4:
		assessment = "Dobry wynik. Podstawy są opanowane, ale część finansów można jeszcze poprawić."
	else:
		assessment = "To dopiero początek. Sprawdź niewykonane cele i spróbuj ponownie z inną strategią."

	return (
		"Minęło 12 tygodni pierwszego rozdziału.\n\n"
		+ "Wykonane cele: %d/%d\n" % [completed, total_goals]
		+ "Majątek netto: %s M$\n" % format_money_decimal(get_net_worth())
		+ "Oszczędności: %s M$\n" % format_money_decimal(savings_balance)
		+ "Wartość akcji: %s M$\n" % format_money_decimal(get_all_stock_value())
		+ "Wynik posiadanych akcji: %s M$\n" % format_money_decimal(get_total_unrealized_profit())
		+ "Wynik ze sprzedaży akcji: %s M$\n" % format_money_decimal(get_total_realized_profit())
		+ "Dług: %s M$\n" % format_money(debt)
		+ "Naliczane odsetki od pożyczek: %s M$\n" % format_money(total_loan_interest_charged)
		+ "Pełne raty / opóźnione raty: %d / %d\n\n" % [loan_payments_made, missed_loan_payments]
		+ assessment
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

	var current_income: int = get_monthly_income()
	cash += current_income
	cash -= MONTHLY_EXPENSES

	if current_month > 12:
		current_month = 1
		current_year += 1

	var report: String = (
		"\n\nROZLICZENIE MIESIĄCA:"
		+ "\nDochód: +%s M$" % format_money(current_income)
		+ "\nWydatki: -%s M$" % format_money(MONTHLY_EXPENSES)
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
