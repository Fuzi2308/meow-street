extends RefCounted


const COMPANY_ORDER = [
	"pawphone",
	"whisker_foods",
	"purr_bank",
	"clawstruction",
	"green_paws_energy"
]


const COMPANY_DEFINITIONS = {
	"pawphone": {
		"name": "PawPhone",
		"ticker": "PAW",
		"sector": "Technologia",
		"risk": "Wysokie",
		"start_price": 100
	},
	"whisker_foods": {
		"name": "WhiskerFoods",
		"ticker": "WFS",
		"sector": "Żywność",
		"risk": "Niskie",
		"start_price": 80
	},
	"purr_bank": {
		"name": "PurrBank",
		"ticker": "PRB",
		"sector": "Bankowość",
		"risk": "Średnie",
		"start_price": 120
	},
	"clawstruction": {
		"name": "Clawstruction",
		"ticker": "CLW",
		"sector": "Budownictwo",
		"risk": "Wysokie",
		"start_price": 65
	},
	"green_paws_energy": {
		"name": "GreenPaws Energy",
		"ticker": "GPE",
		"sector": "Zielona energia",
		"risk": "Wysokie",
		"start_price": 90
	}
}


const MARKET_EVENTS = [
	{
		"headline": "PawPhone zapowiedział przełomowy model telefonu.",
		"changes": {"pawphone": 8, "whisker_foods": 1, "purr_bank": 1, "clawstruction": 0, "green_paws_energy": 2},
		"explanation": "Dobra wiadomość jednej firmy najmocniej wpływa na jej akcje, a pozostałe branże reagują słabiej."
	},
	{
		"headline": "Fabryka PawPhone ma opóźnienia w produkcji.",
		"changes": {"pawphone": -6, "whisker_foods": 1, "purr_bank": -1, "clawstruction": 0, "green_paws_energy": 1},
		"explanation": "Problemy produkcyjne obniżają oczekiwane zyski PawPhone, ale prawie nie dotyczą innych sektorów."
	},
	{
		"headline": "WhiskerFoods podpisał umowę z dużą siecią sklepów.",
		"changes": {"pawphone": 0, "whisker_foods": 7, "purr_bank": 1, "clawstruction": 0, "green_paws_energy": 0},
		"explanation": "Nowy kontrakt może zwiększyć sprzedaż WhiskerFoods i poprawić wyniki spółki."
	},
	{
		"headline": "Ceny energii gwałtownie wzrosły.",
		"changes": {"pawphone": -3, "whisker_foods": -5, "purr_bank": -2, "clawstruction": -4, "green_paws_energy": 8},
		"explanation": "Droższa energia zwiększa koszty wielu firm, ale może poprawić perspektywy producentów zielonej energii."
	},
	{
		"headline": "Konsumenci zaczęli wydawać więcej pieniędzy.",
		"changes": {"pawphone": 5, "whisker_foods": 3, "purr_bank": 2, "clawstruction": 4, "green_paws_energy": 1},
		"explanation": "Wyższa konsumpcja wspiera wiele branż jednocześnie, choć nie każdą w takim samym stopniu."
	},
	{
		"headline": "Pojawiły się obawy przed spowolnieniem gospodarczym.",
		"changes": {"pawphone": -7, "whisker_foods": 2, "purr_bank": -5, "clawstruction": -8, "green_paws_energy": -3},
		"explanation": "Podczas niepewności mocniej tracą branże zależne od kredytów i dużych zakupów, a żywność jest stabilniejsza."
	},
	{
		"headline": "Bank centralny podniósł stopy procentowe.",
		"changes": {"pawphone": -4, "whisker_foods": 0, "purr_bank": 6, "clawstruction": -7, "green_paws_energy": -2},
		"explanation": "Wyższe stopy mogą poprawić marże banków, ale kredyty stają się droższe dla klientów i firm budowlanych."
	},
	{
		"headline": "Bank centralny obniżył stopy procentowe.",
		"changes": {"pawphone": 5, "whisker_foods": 1, "purr_bank": -4, "clawstruction": 7, "green_paws_energy": 4},
		"explanation": "Tańsze kredyty wspierają inwestycje i budownictwo, lecz mogą zmniejszyć część dochodów banków."
	},
	{
		"headline": "Rząd ogłosił dopłaty do odnawialnych źródeł energii.",
		"changes": {"pawphone": 1, "whisker_foods": 0, "purr_bank": 0, "clawstruction": 3, "green_paws_energy": 10},
		"explanation": "Dotacje bezpośrednio poprawiają perspektywy GreenPaws Energy i pośrednio pomagają wykonawcom nowych instalacji."
	},
	{
		"headline": "Clawstruction zdobył duży kontrakt miejski.",
		"changes": {"pawphone": 0, "whisker_foods": 1, "purr_bank": 1, "clawstruction": 9, "green_paws_energy": 2},
		"explanation": "Duże zamówienie zwiększa przewidywane przychody firmy budowlanej."
	},
	{
		"headline": "PurrBank poinformował o poważnym cyberataku.",
		"changes": {"pawphone": -2, "whisker_foods": 0, "purr_bank": -9, "clawstruction": -1, "green_paws_energy": 0},
		"explanation": "Cyberatak zwiększa koszty banku i osłabia zaufanie jego klientów."
	},
	{
		"headline": "Firmy opublikowały lepsze wyniki od oczekiwań.",
		"changes": {"pawphone": 6, "whisker_foods": 4, "purr_bank": 5, "clawstruction": 3, "green_paws_energy": 5},
		"explanation": "Dobre wyniki zwiększają optymizm inwestorów na całym rynku."
	},
	{
		"headline": "Inflacja pozostaje wyższa, niż przewidywano.",
		"changes": {"pawphone": -3, "whisker_foods": 3, "purr_bank": 2, "clawstruction": -5, "green_paws_energy": -1},
		"explanation": "Inflacja wpływa na sektory różnie: część firm może podnosić ceny, a inne cierpią przez rosnące koszty."
	},
	{
		"headline": "Nowe przepisy ograniczą sprzedaż drogich urządzeń elektronicznych.",
		"changes": {"pawphone": -7, "whisker_foods": 1, "purr_bank": 2, "clawstruction": 0, "green_paws_energy": 1},
		"explanation": "Zmiana prawa może uderzyć w konkretną branżę bez większego wpływu na pozostałe firmy."
	},
	{
		"headline": "Na giełdzie wybuchła panika po serii złych informacji.",
		"changes": {"pawphone": -8, "whisker_foods": -4, "purr_bank": -7, "clawstruction": -9, "green_paws_energy": -8},
		"explanation": "Podczas paniki spadają nawet dobre spółki. Dywersyfikacja ogranicza ryzyko pojedynczej firmy, ale nie usuwa ryzyka całego rynku."
	},
	{
		"headline": "Inwestorzy uwierzyli w silne odbicie gospodarki.",
		"changes": {"pawphone": 7, "whisker_foods": 4, "purr_bank": 5, "clawstruction": 6, "green_paws_energy": 8},
		"explanation": "Optymizm zwiększa popyt na akcje, szczególnie spółek o wyższym ryzyku."
	}
]


const LIFE_EVENTS = [
	{
		"id": "broken_laptop",
		"title": "AWARIA LAPTOPA",
		"description": "Laptop potrzebny do nauki i pracy przestał działać. Naprawa jest konieczna.",
		"cost": 1200
	},
	{
		"id": "dentist",
		"title": "PILNA WIZYTA U DENTYSTY",
		"description": "Pojawił się nagły problem z zębem. Leczenia nie warto odkładać.",
		"cost": 900
	},
	{
		"id": "bike_repair",
		"title": "NAPRAWA ROWERU",
		"description": "Rower, którym dojeżdżasz do szkoły lub pracy, wymaga szybkiej naprawy.",
		"cost": 500
	},
	{
		"id": "water_damage",
		"title": "ZALANIE MIESZKANIA",
		"description": "Pęknięta rura uszkodziła część wyposażenia. Musisz pokryć koszt naprawy.",
		"cost": 1100
	},
	{
		"id": "broken_phone",
		"title": "USZKODZONY TELEFON",
		"description": "Telefon upadł i wymaga wymiany ekranu, aby nadal można było z niego korzystać.",
		"cost": 700
	},
	{
		"id": "career_course",
		"title": "KURS ZAWODOWY",
		"description": "Możesz ukończyć kurs zwiększający kwalifikacje. Po opłaceniu kursu miesięczny dochód wzrośnie o 200 M$.",
		"cost": 1400,
		"income_bonus": 200
	}
]
