Config = {}

Config.VerifyJob = "police"         --Job that can check opened bills by person
Config.DaysToKeep = 60              --Number of days to keep the payed invoces into table
Config.DunningCost = 5              --Raise % of the invoice by no payment for costs

Config.Companies = {                --Companies information job based 
    ["mechanic"] = {
        ["Account"] = "bank",       --Account for the payment "cash "bank"
        ['Reference'] = "MECA",     --Job reference for invoice reference
        ['Can_refuse'] = true,      --Can the person refuse to pay
    },    
    ["police"] = {
        ["Account"] = "bank",
        ['Reference'] = "FINE",
        ['Can_refuse'] = false,
    },    
}
