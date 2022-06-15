function findLanguage()
	currentlanguage = Infinity_GetINIString('Language', 'Text', '')
	if currentlanguage == "it_IT" then			-- Italian
			JFStrings = {
			JF_All = "Tutte",
			JF_Active = "Attive",
			JF_Completed = "Completate",
			JF_Notes = "Le Mie Note:",
			JF_Edited = "Aggiornato:"
		}
	elseif currentlanguage == "pl_PL" then			-- Polish
			JFStrings = {
			JF_All = "Wszystkie",
			JF_Active = "Aktywne",
			JF_Completed = "Wykonane",
			JF_Notes = "Moje notatki:",
			JF_Edited = "Zmieniony:"
		}
	elseif currentlanguage == "de_DE" then			-- German
			JFStrings = {
			JF_All = "Alle",
			JF_Active = "Offen",
			JF_Completed = "Abgeschlossen",
			JF_Notes = "Meine Notizen:",
			JF_Edited = "Bearbeitet:"
		}
	elseif currentlanguage == "pt_BR" then			-- Brazilian Portuguese 
			JFStrings = {
			JF_All = "Todas",
			JF_Active = "Ativas",
			JF_Completed = "Concluídas",
			JF_Notes = "Minhas Anotações:",
			JF_Edited = "Editado:"
		}
	elseif currentlanguage == "fr_FR" then			-- French
			JFStrings = {
			JF_All = "Toutes",
			JF_Active = "Actives",
			JF_Completed = "Accomplies",
			JF_Notes = "Mes notes:",
			JF_Edited = "Modifiée:"
		}
	elseif currentlanguage == "cs_CZ" then			-- Czech
			JFStrings = {
			JF_All = "Všechny",
			JF_Active = "Aktivní",
			JF_Completed = "Dokončené",
			JF_Notes = "Poznámky:",
			JF_Edited = "Upravené:"
		}
	elseif currentlanguage == "ru_RU" then			-- Russian
			JFStrings = {
			JF_All = "Все",
			JF_Active = "Активные",
			JF_Completed = "Завершенные",
			JF_Notes = "Мои заметки:",
			JF_Edited = "Изменено:"
		}
	else											-- no matching language or language strings not set, so default to en_US for the extra strings
		JFStrings = {
			JF_All = "All",
			JF_Active = "Active",
			JF_Completed = "Completed",
			JF_Notes = "My Notes:",
			JF_Edited = "Edited:"
		}
	end
end