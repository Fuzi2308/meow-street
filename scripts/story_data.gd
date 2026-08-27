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


# Profile ryzyka są oddzielone od treści decyzji, aby łatwo balansować szanse
# bez przepisywania całej fabuły. Wynik każdej opcji jest losowany w momencie
# pojawienia się decyzji i zapisywany razem ze stanem gry.
const CHOICE_RISK_PROFILES = {
	"first_plan": [
		{"risk": "NISKIE", "risk_note": "Pewny skutek: większa poduszka, ale mniej gotówki."},
		{"risk": "NISKIE", "risk_note": "Pewny koszt bez późniejszego losowania."},
		{"risk": "NISKIE", "risk_note": "Brak kosztu, ale pieniądze nie są oddzielone od wydatków."}
	],
	"career_course": [
		{
			"risk": "ŚREDNIE",
			"risk_note": "70%: dochód +250 M$ • 20%: +150 M$ • 10%: brak podwyżki.",
			"outcomes": [
				{"weight": 70, "name": "Pełny efekt kursu", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 250}, "report": "Kurs intensywny przyniósł pełny efekt. Dochód rośnie o 250 M$ miesięcznie."}]},
				{"weight": 20, "name": "Częściowy efekt kursu", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 150}, "report": "Kurs intensywny pomógł częściowo. Dochód rośnie o 150 M$ miesięcznie."}]},
				{"weight": 10, "name": "Brak wzrostu dochodu", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Kurs poszerzył wiedzę, ale na razie nie zwiększył dochodu."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "75%: dochód +100 M$ • 20%: +50 M$ • 5%: brak podwyżki.",
			"outcomes": [
				{"weight": 75, "name": "Pełny efekt kursu", "delayed_effects": [{"delay_weeks": 6, "effects": {"monthly_income_bonus": 100}, "report": "Kurs podstawowy przyniósł zakładany efekt. Dochód rośnie o 100 M$ miesięcznie."}]},
				{"weight": 20, "name": "Częściowy efekt kursu", "delayed_effects": [{"delay_weeks": 6, "effects": {"monthly_income_bonus": 50}, "report": "Kurs podstawowy pomógł częściowo. Dochód rośnie o 50 M$ miesięcznie."}]},
				{"weight": 5, "name": "Brak wzrostu dochodu", "delayed_effects": [{"delay_weeks": 6, "effects": {}, "report": "Kurs podstawowy nie przełożył się jeszcze na wyższy dochód."}]}
			]
		},
		{"risk": "NISKIE", "risk_note": "Nie tracisz gotówki, ale rezygnujesz z możliwego wzrostu dochodu."}
	],
	"work_laptop": [
		{"risk": "NISKIE", "risk_note": "Pewny koszt i przewidywalny wzrost dochodu."},
		{
			"risk": "WYSOKIE",
			"risk_note": "55%: brak awarii • 30%: koszt 450 M$ • 15%: koszt 900 M$.",
			"outcomes": [
				{"weight": 55, "name": "Naprawa trwała", "delayed_effects": [{"delay_weeks": 10, "effects": {}, "report": "Naprawiony laptop nadal działa. Nie ponosisz kolejnego kosztu."}]},
				{"weight": 30, "name": "Kolejna naprawa", "delayed_effects": [{"delay_weeks": 10, "effects": {"mandatory_cost": 450}, "report": "Laptop ponownie się zepsuł. Naprawa kosztowała 450 M$."}]},
				{"weight": 15, "name": "Poważna awaria", "delayed_effects": [{"delay_weeks": 10, "effects": {"mandatory_cost": 900}, "report": "Laptop uległ poważnej awarii. Pilny koszt wyniósł 900 M$."}]}
			]
		},
		{"risk": "ŚREDNIE", "risk_note": "Sprzęt pomaga w pracy, ale dług obciąża każdy kolejny tydzień."}
	],
	"housing": [
		{"risk": "NISKIE", "risk_note": "Duży koszt początkowy, ale przewidywalna oszczędność."},
		{"risk": "NISKIE", "risk_note": "Brak zmiany kosztów i brak ryzyka przeprowadzki."},
		{
			"risk": "WYSOKIE",
			"risk_note": "45%: bez napraw • 35%: koszt 500 M$ • 20%: koszt 1 000 M$.",
			"outcomes": [
				{"weight": 45, "name": "Brak ukrytych wad", "delayed_effects": [{"delay_weeks": 12, "effects": {}, "report": "Tanie mieszkanie nie ujawniło poważnych wad. Unikasz dodatkowego kosztu."}]},
				{"weight": 35, "name": "Drobna wada", "delayed_effects": [{"delay_weeks": 12, "effects": {"mandatory_cost": 500}, "report": "Ukryta wada mieszkania wymaga naprawy za 500 M$."}]},
				{"weight": 20, "name": "Poważna wada", "delayed_effects": [{"delay_weeks": 12, "effects": {"mandatory_cost": 1000}, "report": "Tanie mieszkanie wymaga pilnego remontu za 1 000 M$."}]}
			]
		}
	],
	"hot_tip": [
		{
			"risk": "WYSOKIE",
			"risk_note": "25%: +18% • 20%: +5% • 55%: -15% kursu PAW.",
			"outcomes": [
				{"weight": 25, "name": "Plotka się potwierdziła", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": 18}}, "report": "Plotka o PawPhone się potwierdziła. Kurs rośnie dodatkowo o 18%."}]},
				{"weight": 20, "name": "Niewielki wzrost", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": 5}}, "report": "PawPhone rośnie dodatkowo o 5%, znacznie mniej od obietnic."}]},
				{"weight": 55, "name": "Plotka była fałszywa", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": -15}}, "report": "Plotka była przesadzona. PawPhone spada dodatkowo o 15%."}]}
			]
		},
		{
			"risk": "WYSOKIE",
			"risk_note": "25%: +18% • 20%: +5% • 55%: -15%; ryzykujesz mniejszą kwotę.",
			"outcomes": [
				{"weight": 25, "name": "Plotka się potwierdziła", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": 18}}, "report": "Plotka o PawPhone się potwierdziła. Kurs rośnie dodatkowo o 18%."}]},
				{"weight": 20, "name": "Niewielki wzrost", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": 5}}, "report": "PawPhone rośnie dodatkowo o 5%, znacznie mniej od obietnic."}]},
				{"weight": 55, "name": "Plotka była fałszywa", "delayed_effects": [{"delay_weeks": 4, "effects": {"company_price_change": {"company_id": "pawphone", "percent": -15}}, "report": "Plotka była przesadzona. PawPhone spada dodatkowo o 15%."}]}
			]
		},
		{"risk": "NISKIE", "risk_note": "Nie ryzykujesz kapitału na podstawie niepotwierdzonej informacji."}
	],
	"subscriptions": [
		{"risk": "NISKIE", "risk_note": "Pewne obniżenie regularnych wydatków."},
		{"risk": "NISKIE", "risk_note": "Brak natychmiastowej zmiany, ale opłaty pozostają."},
		{
			"risk": "ŚREDNIE",
			"risk_note": "70%: dochód +140 M$ • 20%: +70 M$ • 10%: brak wzrostu.",
			"outcomes": [
				{"weight": 70, "name": "Nauka wykorzystana", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 140}, "report": "Platforma edukacyjna przyniosła efekty. Dochód rośnie o 140 M$ miesięcznie."}]},
				{"weight": 20, "name": "Częściowy efekt", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 70}, "report": "Nauka pomogła częściowo. Dochód rośnie o 70 M$ miesięcznie."}]},
				{"weight": 10, "name": "Brak efektu finansowego", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Subskrypcja nie przełożyła się na wyższy dochód."}]}
			]
		}
	],
	"promotion": [
		{
			"risk": "ŚREDNIE",
			"risk_note": "65%: dochód +350 M$ • 25%: +180 M$ • 10%: brak awansu.",
			"outcomes": [
				{"weight": 65, "name": "Awans", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 350}, "report": "Zdobyłeś awans. Dochód rośnie o 350 M$ miesięcznie."}]},
				{"weight": 25, "name": "Mniejsza podwyżka", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 180}, "report": "Nie zdobyłeś stanowiska, ale otrzymałeś podwyżkę 180 M$ miesięcznie."}]},
				{"weight": 10, "name": "Brak awansu", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Rekrutacja zakończyła się bez awansu i bez podwyżki."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "50%: dochód +120 M$ • 30%: +60 M$ • 20%: brak podwyżki.",
			"outcomes": [
				{"weight": 50, "name": "Podwyżka", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 120}, "report": "Otrzymałeś podwyżkę. Dochód rośnie o 120 M$ miesięcznie."}]},
				{"weight": 30, "name": "Mała podwyżka", "delayed_effects": [{"delay_weeks": 8, "effects": {"monthly_income_bonus": 60}, "report": "Otrzymałeś mniejszą podwyżkę: 60 M$ miesięcznie."}]},
				{"weight": 20, "name": "Brak podwyżki", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Podstawowe przygotowanie nie wystarczyło do zdobycia podwyżki."}]}
			]
		},
		{"risk": "NISKIE", "risk_note": "Nie ponosisz kosztu, ale nie wykorzystujesz szansy na wyższy dochód."}
	],
	"family_help": [
		{
			"risk": "WYSOKIE",
			"risk_note": "65%: zwrot 800 M$ • 25%: zwrot 400 M$ • 10%: brak zwrotu.",
			"outcomes": [
				{"weight": 65, "name": "Pełny zwrot", "delayed_effects": [{"delay_weeks": 8, "effects": {"cash": 800}, "report": "Pożyczone pieniądze wróciły z podziękowaniem: +800 M$."}]},
				{"weight": 25, "name": "Częściowy zwrot", "delayed_effects": [{"delay_weeks": 8, "effects": {"cash": 400}, "report": "Bliska osoba oddała tylko część pieniędzy: +400 M$."}]},
				{"weight": 10, "name": "Brak zwrotu", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Pożyczone 700 M$ nie wróciło w uzgodnionym terminie."}]}
			]
		},
		{"risk": "NISKIE", "risk_note": "Koszt jest pewny i nie oczekujesz zwrotu."},
		{"risk": "NISKIE", "risk_note": "Zachowujesz środki i własną płynność."}
	],
	"insurance": [
		{
			"risk": "NISKIE",
			"risk_note": "65%: brak awarii • 35%: koszt własny 200 M$; składka pozostaje.",
			"outcomes": [
				{"weight": 65, "name": "Brak awarii", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "W tym okresie nie doszło do awarii. Ochrona nie była potrzebna."}]},
				{"weight": 35, "name": "Awaria objęta ochroną", "delayed_effects": [{"delay_weeks": 8, "effects": {"mandatory_cost": 200}, "report": "Doszło do awarii, ale ubezpieczenie ograniczyło koszt do 200 M$."}]}
			]
		},
		{
			"risk": "WYSOKIE",
			"risk_note": "65%: brak awarii • 25%: koszt 600 M$ • 10%: koszt 1 200 M$.",
			"outcomes": [
				{"weight": 65, "name": "Brak awarii", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Sprzęt działa bez awarii. Tym razem uniknąłeś kosztu."}]},
				{"weight": 25, "name": "Mniejsza awaria", "delayed_effects": [{"delay_weeks": 8, "effects": {"mandatory_cost": 600}, "report": "Nieubezpieczona awaria kosztowała 600 M$."}]},
				{"weight": 10, "name": "Poważna awaria", "delayed_effects": [{"delay_weeks": 8, "effects": {"mandatory_cost": 1200}, "report": "Poważna nieubezpieczona awaria kosztowała 1 200 M$."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "65%: rezerwa zostaje • 25%: koszt 300 M$ • 10%: koszt 600 M$.",
			"outcomes": [
				{"weight": 65, "name": "Rezerwa niewykorzystana", "delayed_effects": [{"delay_weeks": 8, "effects": {}, "report": "Nie doszło do awarii. Rezerwa 600 M$ nadal pracuje na koncie oszczędnościowym."}]},
				{"weight": 25, "name": "Drobna awaria", "delayed_effects": [{"delay_weeks": 8, "effects": {"savings_cost": 300}, "report": "Drobna awaria kosztowała 300 M$; środki pobrano najpierw z rezerwy."}]},
				{"weight": 10, "name": "Poważna awaria", "delayed_effects": [{"delay_weeks": 8, "effects": {"savings_cost": 600}, "report": "Poważna awaria wykorzystała całą rezerwę 600 M$."}]}
			]
		}
	],
	"freelance": [
		{
			"risk": "ŚREDNIE",
			"risk_note": "60%: dochód +250 M$ • 30%: +150 M$ • 10%: brak zleceń.",
			"outcomes": [
				{"weight": 60, "name": "Dużo zleceń", "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 250}, "report": "Profesjonalne narzędzia przyciągnęły zlecenia. Dochód rośnie o 250 M$ miesięcznie."}]},
				{"weight": 30, "name": "Kilka zleceń", "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 150}, "report": "Pojawiło się kilka zleceń. Dochód rośnie o 150 M$ miesięcznie."}]},
				{"weight": 10, "name": "Brak zleceń", "delayed_effects": [{"delay_weeks": 4, "effects": {}, "report": "Mimo dobrych narzędzi nie udało się jeszcze pozyskać zleceń."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "50%: dochód +80 M$ • 30%: +40 M$ • 20%: brak zleceń.",
			"outcomes": [
				{"weight": 50, "name": "Regularne małe zlecenia", "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 80}, "report": "Podstawowe narzędzia wystarczyły. Dochód rośnie o 80 M$ miesięcznie."}]},
				{"weight": 30, "name": "Pojedyncze zlecenia", "delayed_effects": [{"delay_weeks": 4, "effects": {"monthly_income_bonus": 40}, "report": "Pojawiły się pojedyncze zlecenia. Dochód rośnie o 40 M$ miesięcznie."}]},
				{"weight": 20, "name": "Brak zleceń", "delayed_effects": [{"delay_weeks": 4, "effects": {}, "report": "Podstawowe narzędzia nie wystarczyły jeszcze do zdobycia klientów."}]}
			]
		},
		{"risk": "NISKIE", "risk_note": "Nie ponosisz kosztu, ale nie tworzysz dodatkowego źródła dochodu."}
	],
	"market_panic": [
		{
			"risk": "WYSOKIE",
			"risk_note": "Sprzedaż jest nieodwracalna • 50%: rynek +10% • 25%: -8% • 25%: bez zmiany.",
			"outcomes": [
				{"weight": 50, "name": "Odbicie rynku", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": 10}, "report": "Rynek odbił dodatkowo o 10%. Sprzedany portfel nie uczestniczy już w tym ruchu."}]},
				{"weight": 25, "name": "Dalszy spadek", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": -8}, "report": "Rynek spadł dodatkowo o 8%. Sprzedaż ograniczyła dalszą ekspozycję."}]},
				{"weight": 25, "name": "Stabilizacja", "delayed_effects": [{"delay_weeks": 4, "effects": {}, "report": "Rynek ustabilizował się bez dodatkowego silnego ruchu."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "50%: rynek +10% • 25%: rynek -8% • 25%: bez zmiany.",
			"outcomes": [
				{"weight": 50, "name": "Odbicie rynku", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": 10}, "report": "Nastroje poprawiły się. Rynek odbija dodatkowo o 10%."}]},
				{"weight": 25, "name": "Dalszy spadek", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": -8}, "report": "Negatywne nastroje trwają. Rynek spada dodatkowo o 8%."}]},
				{"weight": 25, "name": "Stabilizacja", "delayed_effects": [{"delay_weeks": 4, "effects": {}, "report": "Rynek ustabilizował się bez dodatkowego silnego ruchu."}]}
			]
		},
		{
			"risk": "ŚREDNIE",
			"risk_note": "Mniejsza ekspozycja • 50%: rynek +10% • 25%: -8% • 25%: bez zmiany.",
			"outcomes": [
				{"weight": 50, "name": "Odbicie rynku", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": 10}, "report": "Rynek odbija dodatkowo o 10%; zachowana połowa portfela uczestniczy we wzroście."}]},
				{"weight": 25, "name": "Dalszy spadek", "delayed_effects": [{"delay_weeks": 4, "effects": {"all_company_change_percent": -8}, "report": "Rynek spada dodatkowo o 8%; sprzedaż połowy ograniczyła stratę."}]},
				{"weight": 25, "name": "Stabilizacja", "delayed_effects": [{"delay_weeks": 4, "effects": {}, "report": "Rynek ustabilizował się bez dodatkowego silnego ruchu."}]}
			]
		}
	],
	"year_end": [
		{"risk": "NISKIE", "risk_note": "Pewne zwiększenie oszczędności kosztem bieżącej gotówki."},
		{"risk": "NISKIE", "risk_note": "Pewne zmniejszenie długu i przyszłych odsetek."},
		{"risk": "NISKIE", "risk_note": "Zachowujesz płynność • brak wzrostu oszczędności • brak spłaty długu."}
	]
}


static func get_decision_for_week(chapter_week: int) -> Dictionary:
	if not STORY_DECISIONS.has(chapter_week):
		return {}
	var decision: Dictionary = STORY_DECISIONS[chapter_week].duplicate(true)
	var decision_id: String = str(decision.get("id", ""))
	var profiles: Array = CHOICE_RISK_PROFILES.get(decision_id, [])
	var choices: Array = decision.get("choices", [])
	for choice_index in range(choices.size()):
		var choice: Dictionary = choices[choice_index]
		choice["risk"] = "NISKIE"
		choice["risk_note"] = "Skutek tej opcji jest przewidywalny."
		if choice_index < profiles.size():
			var profile: Dictionary = profiles[choice_index]
			for profile_key in profile.keys():
				choice[profile_key] = profile[profile_key]
		choices[choice_index] = choice
	decision["choices"] = choices
	return decision


static func get_decision_count() -> int:
	return STORY_DECISIONS.size()


static func get_decision_summary_by_id(decision_id: String) -> Dictionary:
	for week_value in STORY_DECISIONS.keys():
		var decision: Dictionary = STORY_DECISIONS[week_value]
		if str(decision.get("id", "")) == decision_id:
			return {
				"week": int(week_value),
				"title": str(decision.get("title", "DECYZJA"))
			}
	return {}
