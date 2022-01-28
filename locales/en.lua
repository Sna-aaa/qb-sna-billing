local Translations = {
    error = {
        not_online = "Player is not online",
        not_enough = "You dont have enough money..",
        not_correct_job = "You don't have the correct job",
    },
    success = {
        you_payed = "You paid the bill for $%{value}",
        payed_you = "%{value} Payed you paid the bill for $%{value2}"
    },
    info = {
        show_open_bills = "Show open bills for company",
        show_closed_bills = "Show closed bills for you or company",
        unpayed_bills = "Show unpayed bills",
        create_bill = "Create a bill to send to customer",
        bill_value = "Bill %{value} for $%{value2}",
        pay_immediate = "You just received a bill from %{value} for %{value2} of $%{value3}, Do you want to pay it immediately?",
        open_bills = "Open Bills for %{value}",
        show_bills = "%{value}",
        show_bills_txt = "Date %{value} | Value $%{value2}<br>Customer %{value3}",
        bill_detail = "%{value}",
        bill_detail_txt = "Date %{value}<br>Customer: %{value2}<br>Amount: %{value3}<br>Reason: %{value4}",
        bill_cancelled = "The bill ref %{value} was cancelled",
        bill_mail = "You have been sent a bill for, <br>Amount: <br> $%{value} for %{value2}<br><br> press the button below to accept the bill",
        total_period = "Total: $%{value}",
        stats_for_company = "Stats for company %{value}",
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end
