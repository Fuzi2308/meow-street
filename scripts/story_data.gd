extends RefCounted


const STORY_DECISIONS = {
	1: {
		"id": "first_plan",
		"title": "PIERWSZY PLAN FINANSOWY",
		"description": "Masz 2 500 M$ i cały rok przed sobą. Jak wykorzystasz pierwszy kapitał?",
		"choices": [
			{"title": "ODŁÓŻ 600 M$", "details": "Zacznij budować poduszkę.", "requirements": {"cash": 600}, "effects": {"cash": -600, "savings": 600}, "result": "Odłożyłeś 600 M$ i poprawiłeś bezpieczeństwo.", "education": "Oszczędzanie zaraz po otrzymaniu pieniędzy pomaga utrzymać plan."},
			{"title": "KUP POTRZEBNE RZECZY — 350 M$", "details": "Wyposażenie do nauki i pracy.", "requirements": {"cash": 350}, "effects": {"cash": -350}, "result": "Wydałeś 350 M$ na rzeczy, których będziesz używać.", "education": "Wydatek ma sens, jeśli realizuje potrzebę i mieści się w budżecie."},
			{"title": "ZACHOWAJ GOTÓWKĘ", "details": "Na razie nie wydawaj ani nie przenoś pieniędzy.", "effects": {}, "result": "Zachowałeś pełną płynność na pierwsze tygodnie.", "education": "Gotówka daje elastyczność, ale bez osobnego planu łatwiej wydać ją później przypadkowo."}
		]
	},
	5: {
		"id": "career_course",
		"title": "INWESTYCJA W UMIEJĘTNOŚCI",
		"description": "Kurs może zwiększyć przyszłe dochody, lecz efekt pojawi się dopiero po kilku tygodniach.",
		"choices": [
			{"title": "KURS INTENSYWNY — 900 M$", "details": "Za 8 tygodni dochód +250 M$ miesięcznie.", "requirements": {"cash": 900}, "effects": {"cash": -900}, "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 250}, "report": "Ukończyłeś kurs intensywny. Dochód rośnie o 250 M$ miesięcznie."}], "result": "Zapłaciłeś za kurs; na rezultat poczekasz 8 tygodni.", "education": "Inwestycja w umiejętności zmniejsza gotówkę dziś, ale może trwale podnieść dochody."},
			{"title": "KURS PODSTAWOWY — 400 M$", "details": "Za 6 tygodni dochód +100 M$ miesięcznie.", "requirements": {"cash": 400}, "effects": {"cash": -400}, "delayed_effects": [{"delay_weeks": 6, "effects": {"monthly_income_bonus": 100}, "report": "Ukończyłeś kurs podstawowy. Dochód rośnie o 100 M$ miesięcznie."}], "result": "Wybrałeś tańszy kurs z mniejszą przyszłą korzyścią.", "education": "Porównuj koszt, możliwy zysk oraz czas oczekiwania na efekt."},
			{"title": "ZREZYGNUJ Z KURSU", "details": "Zachowaj gotówkę.", "effects": {}, "result": "Zachowałeś pieniądze, ale dochód się nie zwiększy.", "education": "Brak wydatku chroni płynność, lecz może oznaczać utraconą możliwość."}
		]
	},
	9: {
		"id": "work_laptop",
		"title": "SPRZĘT DO PRACY",
		"description": "Stary laptop przeszkadza w pracy. Lepszy sprzęt może zwiększyć dochody.",
		"choices": [
			{"title": "KUP ZA GOTÓWKĘ — 1 200 M$", "details": "Za 4 tygodnie dochód +120 M$ miesięcznie.", "requirements": {"cash": 1200}, "effects": {"cash": -1200}, "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 120}, "report": "Nowy laptop usprawnił pracę. Dochód rośnie o 120 M$ miesięcznie."}], "result": "Kupiłeś laptop bez zadłużenia.", "education": "Gotówka nie tworzy odsetek, ale zmniejsza rezerwę na nagłe wydatki."},
			{"title": "NAPRAW STARY — 350 M$", "details": "Taniej teraz, lecz możliwa kolejna awaria.", "requirements": {"cash": 350}, "effects": {"cash": -350}, "delayed_effects": [{"delay_weeks": 10, "effects": {"mandatory_cost": 450}, "report": "Stary laptop zepsuł się ponownie. Naprawa kosztowała 450 M$."}], "result": "Naprawiłeś sprzęt, ale ryzyko awarii pozostało.", "education": "Najtańsza opcja początkowa nie zawsze ma najniższy koszt całkowity."},
			{"title": "KUP NA RATY — 1 500 M$ DŁUGU", "details": "Sprzęt od razu, spłata z odsetkami.", "effects": {"debt": 1500}, "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 120}, "report": "Nowy laptop usprawnił pracę. Dochód rośnie o 120 M$ miesięcznie."}], "result": "Masz nowy sprzęt oraz 1 500 M$ długu.", "education": "Raty oszczędzają gotówkę dziś, ale obciążają przyszły budżet."}
		]
	},
	13: {
		"id": "housing",
		"title": "TAŃSZE MIESZKANIE",
		"description": "Przeprowadzka kosztuje dziś, lecz może obniżyć regularne wydatki.",
		"choices": [
			{"title": "PRZEPROWADŹ SIĘ — 900 M$", "details": "Za 4 tygodnie wydatki -250 M$ miesięcznie.", "requirements": {"cash": 900}, "effects": {"cash": -900}, "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_expense_modifier": -250}, "report": "Przeprowadzka zakończona. Wydatki spadają o 250 M$ miesięcznie."}], "result": "Opłaciłeś przeprowadzkę; oszczędność pojawi się później.", "education": "Jednorazowy koszt może się zwrócić dzięki niższym stałym wydatkom."},
			{"title": "ZOSTAŃ W OBECNYM MIEJSCU", "details": "Brak kosztu i brak oszczędności.", "effects": {}, "result": "Zachowałeś gotówkę i dotychczasowe koszty.", "education": "Stabilność ma wartość, zwłaszcza przy małej poduszce."},
			{"title": "NAJTAŃSZA OFERTA — 300 M$", "details": "Wydatki -120 M$, lecz możliwa naprawa.", "requirements": {"cash": 300}, "effects": {"cash": -300, "monthly_expense_modifier": -120}, "delayed_effects": [{"delay_weeks": 12, "effects": {"mandatory_cost": 500}, "report": "Ukryta wada mieszkania wymaga naprawy za 500 M$."}], "result": "Od razu płacisz mniej, ale przyjąłeś dodatkowe ryzyko.", "education": "Niska cena nie zawsze oznacza najlepszą wartość."}
		]
	},
	17: {
		"id": "hot_tip",
		"title": "GORĄCY TIP INWESTYCYJNY",
		"description": "Znajomy obiecuje szybki wzrost PawPhone, ale nie pokazuje wiarygodnych danych.",
		"choices": [
			{"title": "KUP 5 AKCJI PAW", "details": "Duża pozycja oparta na plotce.", "requirements": {"stock_cash": {"company_id": "pawphone", "quantity": 5}}, "effects": {"stock_purchase": {"company_id": "pawphone", "quantity": 5}}, "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": -12}}, "report": "Plotka była przesadzona. PawPhone spada dodatkowo o 12%."}], "result": "Kupiłeś 5 akcji bez własnej analizy.", "education": "Niesprawdzona informacja połączona z dużą pozycją zwiększa ryzyko."},
			{"title": "KUP 2 AKCJE PAW", "details": "Ogranicz ryzykowaną kwotę.", "requirements": {"stock_cash": {"company_id": "pawphone", "quantity": 2}}, "effects": {"stock_purchase": {"company_id": "pawphone", "quantity": 2}}, "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": -12}}, "report": "Plotka była przesadzona. PawPhone spada dodatkowo o 12%."}], "result": "Zaryzykowałeś mniejszą kwotę.", "education": "Mniejsza pozycja ogranicza stratę, ale nie poprawia jakości informacji."},
			{"title": "NIE KUPUJ NA PODSTAWIE PLOTKI", "details": "Poczekaj na wiarygodne dane.", "effects": {}, "result": "Nie uległeś presji szybkiego zysku.", "education": "Brak transakcji także jest decyzją."}
		]
	},
	21: {
		"id": "subscriptions",
		"title": "PRZEGLĄD SUBSKRYPCJI",
		"description": "Małe opłaty zaczęły obciążać budżet.",
		"choices": [
			{"title": "ANULUJ NIEUŻYWANE USŁUGI", "details": "Wydatki -150 M$ miesięcznie.", "effects": {"monthly_expense_modifier": -150}, "result": "Obniżyłeś regularne wydatki o 150 M$.", "education": "Małe opłaty kumulują się i warto regularnie je przeglądać."},
			{"title": "NIC NIE ZMIENIAJ", "details": "Budżet bez zmian.", "effects": {}, "result": "Pozostawiłeś wszystkie opłaty.", "education": "Brak działania również ma koszt alternatywny."},
			{"title": "PLATFORMA DO NAUKI", "details": "Wydatki +80 M$; za 8 tygodni dochód +140 M$.", "effects": {"monthly_expense_modifier": 80}, "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 140}, "report": "Nauka przynosi efekty. Dochód rośnie o 140 M$ miesięcznie."}], "result": "Dodałeś usługę edukacyjną za 80 M$ miesięcznie.", "education": "Regularny koszt może być inwestycją, jeśli prowadzi do trwałych korzyści."}
		]
	},
	25: {
		"id": "promotion",
		"title": "SZANSA NA AWANS",
		"description": "Przygotowanie do rekrutacji kosztuje, lecz może zwiększyć pensję.",
		"choices": [
			{"title": "PEŁNE PRZYGOTOWANIE — 1 000 M$", "details": "Za 8 tygodni dochód +350 M$.", "requirements": {"cash": 1000}, "effects": {"cash": -1000}, "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 350}, "report": "Zdobyłeś awans. Dochód rośnie o 350 M$ miesięcznie."}], "result": "Mocno zainwestowałeś w awans.", "education": "Wysoki koszt ma sens, gdy realistyczna korzyść jest trwała."},
			{"title": "PODSTAWOWE PRZYGOTOWANIE — 300 M$", "details": "Za 8 tygodni dochód +120 M$.", "requirements": {"cash": 300}, "effects": {"cash": -300}, "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 120}, "report": "Otrzymałeś podwyżkę. Dochód rośnie o 120 M$ miesięcznie."}], "result": "Ograniczyłeś koszt i możliwą korzyść.", "education": "Mniejsza inwestycja zwykle oznacza mniejsze ryzyko i mniejszy zysk."},
			{"title": "NIE STARTUJ", "details": "Zachowaj pieniądze i obecną pensję.", "effects": {}, "result": "Nie podjąłeś ryzyka.", "education": "Unikanie każdej inwestycji może ograniczać długoterminowy rozwój."}
		]
	},
	29: {
		"id": "family_help",
		"title": "PROŚBA O POMOC",
		"description": "Bliska osoba prosi o pieniądze i obiecuje zwrot za dwa miesiące.",
		"choices": [
			{"title": "POŻYCZ 700 M$", "details": "Za 8 tygodni otrzymasz 800 M$.", "requirements": {"cash": 700}, "effects": {"cash": -700}, "delayed_effects": [{"delay_weeks": 8, "effects": {"cash": 800}, "report": "Pożyczka wróciła: +800 M$."}], "result": "Przez 8 tygodni nie możesz korzystać z 700 M$.", "education": "Pożyczone środki przestają być płynne, nawet gdy oczekujesz zwrotu."},
			{"title": "PODARUJ 300 M$", "details": "Mniejsza pomoc bez zwrotu.", "requirements": {"cash": 300}, "effects": {"cash": -300}, "result": "Pomogłeś kwotą 300 M$.", "education": "Pomoc może być częścią budżetu, jeśli nie zagraża zobowiązaniom."},
			{"title": "ODMÓW FINANSOWO", "details": "Zachowaj środki.", "effects": {}, "result": "Zachowałeś własną płynność.", "education": "Granice finansowe są ważne."}
		]
	},
	33: {
		"id": "insurance",
		"title": "UBEZPIECZENIE SPRZĘTU",
		"description": "Za 8 tygodni zdarzy się awaria. Dzisiejszy wybór określi jej koszt.",
		"choices": [
			{"title": "WYKUP UBEZPIECZENIE", "details": "Wydatki +100 M$; awaria 200 M$.", "effects": {"monthly_expense_modifier": 100}, "delayed_effects": [{"delay_weeks": 8, "effects": {"mandatory_cost": 200}, "report": "Awaria kosztowała tylko 200 M$ dzięki ubezpieczeniu."}], "result": "Zamieniłeś duże ryzyko na regularną składkę.", "education": "Ubezpieczenie ogranicza nieprzewidywalność kosztem stałej opłaty."},
			{"title": "PODEJMIJ RYZYKO", "details": "Brak składki; awaria 1 200 M$.", "effects": {}, "delayed_effects": [{"delay_weeks": 8, "effects": {"mandatory_cost": 1200}, "report": "Brak ubezpieczenia oznacza koszt awarii 1 200 M$."}], "result": "Wziąłeś pełne ryzyko na siebie.", "education": "Samodzielne pokrywanie ryzyka wymaga odpowiednio dużej rezerwy."},
			{"title": "ODŁÓŻ REZERWĘ 600 M$", "details": "Przygotuj własny fundusz naprawczy.", "requirements": {"cash": 600}, "effects": {"cash": -600, "savings": 600}, "delayed_effects": [{"delay_weeks": 8, "effects": {"savings_cost": 600}, "report": "Awaria kosztowała 600 M$; system użył najpierw przygotowanych oszczędności."}], "result": "Utworzyłeś fundusz celowy.", "education": "Mniejsze ryzyka można zabezpieczać własną rezerwą."}
		]
	},
	37: {
		"id": "freelance",
		"title": "PIERWSZE ZLECENIA",
		"description": "Możesz rozpocząć dodatkową pracę, kupując potrzebne narzędzia.",
		"choices": [
			{"title": "PROFESJONALNE NARZĘDZIA — 900 M$", "details": "Za 4 tygodnie dochód +250 M$.", "requirements": {"cash": 900}, "effects": {"cash": -900}, "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 250}, "report": "Zlecenia zwiększają dochód o 250 M$ miesięcznie."}], "result": "Przygotowałeś profesjonalny warsztat.", "education": "Narzędzie zarobkowe jest inwestycją, jeśli przychód jest realistyczny."},
			{"title": "PODSTAWOWE NARZĘDZIA — 250 M$", "details": "Za 4 tygodnie dochód +80 M$.", "requirements": {"cash": 250}, "effects": {"cash": -250}, "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 80}, "report": "Małe zlecenia zwiększają dochód o 80 M$ miesięcznie."}], "result": "Zacząłeś ostrożnie.", "education": "Mały test pomysłu ogranicza ryzyko przed większą inwestycją."},
			{"title": "ZREZYGNUJ", "details": "Zachowaj gotówkę.", "effects": {}, "result": "Nie utworzyłeś nowego źródła dochodu.", "education": "Dodatkowy dochód wymaga czasu, kapitału albo obu."}
		]
	},
	41: {
		"id": "market_panic",
		"title": "PANIKA NA RYNKU",
		"description": "Po serii złych wiadomości inwestorzy sprzedają akcje pod wpływem emocji.",
		"choices": [
			{"title": "SPRZEDAJ WSZYSTKO", "details": "Zamknij cały portfel.", "requirements": {"shares_min": 1}, "effects": {"sell_all_stocks": true}, "result": "Sprzedałeś cały portfel podczas paniki.", "education": "Sprzedaż utrwala wynik i może pozbawić udziału w odbiciu."},
			{"title": "UTRZYMAJ PORTFEL", "details": "Za 4 tygodnie rynek odbije o 8%.", "effects": {}, "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": 8}, "report": "Nastroje poprawiły się. Rynek odbija dodatkowo o 8%."}], "result": "Nie wykonałeś nerwowej transakcji.", "education": "Plan pomaga oddzielić emocje od decyzji inwestycyjnych."},
			{"title": "SPRZEDAJ POŁOWĘ", "details": "Zmniejsz ryzyko, ale zachowaj część portfela.", "requirements": {"shares_min": 1}, "effects": {"sell_half_stocks": true}, "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": 8}, "report": "Nastroje poprawiły się. Rynek odbija dodatkowo o 8%."}], "result": "Ograniczyłeś ryzyko i udział w możliwym odbiciu.", "education": "Częściowa sprzedaż jest rozwiązaniem pośrednim."}
		]
	},
	45: {
		"id": "year_end",
		"title": "PLAN NA KONIEC ROKU",
		"description": "Wzmocnisz poduszkę, zmniejszysz dług czy zachowasz płynność?",
		"choices": [
			{"title": "ODŁÓŻ 1 500 M$", "details": "Przenieś gotówkę na oszczędności.", "requirements": {"cash": 1500}, "effects": {"cash": -1500, "savings": 1500}, "result": "Poduszka wzrosła o 1 500 M$.", "education": "Przeniesienie środków nie zmienia majątku, ale chroni rezerwę przed wydaniem."},
			{"title": "SPŁAĆ DO 1 500 M$ DŁUGU", "details": "Kwota zależy od gotówki i długu.", "requirements": {"cash": 1, "debt_min": 1}, "effects": {"repay_debt": 1500}, "result": "Zmniejszyłeś zadłużenie dostępną kwotą.", "education": "Spłata długu daje pewną korzyść w postaci unikniętych odsetek."},
			{"title": "ZACHOWAJ GOTÓWKĘ", "details": "Nie zmieniaj struktury majątku.", "effects": {}, "result": "Zachowałeś maksymalną płynność.", "education": "Gotówka daje elastyczność, choć zwykle nie pracuje jak inwestycje."}
		]
	}
}


static func get_decision_for_week(chapter_week: int) -> Dictionary:
	if not STORY_DECISIONS.has(chapter_week):
		return {}
	return STORY_DECISIONS[chapter_week].duplicate(true)


static func get_decision_count() -> int:
	return STORY_DECISIONS.size()
