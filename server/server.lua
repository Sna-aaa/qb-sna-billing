local QBCore = exports['qb-core']:GetCoreObject()

--Commands
QBCore.Commands.Add("showbills", Lang:t("info.show_open_bills"), {}, false, function(source, args)
    TriggerEvent('qb-billing:server:ShowBills', source)
end)

QBCore.Commands.Add("statbills", Lang:t("info.show_closed_bills"), {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.isboss then
        TriggerEvent('qb-billing:server:ShowStatsForCompany', source)
    else
        TriggerEvent('qb-billing:server:ShowStatsForEmployee', source, Player.PlayerData.citizenid, Player.PlayerData.job.name)
    end
end)

QBCore.Commands.Add("createbill", Lang:t("info.create_bill"), {{name="id", help="Player ID"},{name="amount", help="Value of the bill"},{name="reason", help="Reason for the bill"}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player ~= nil then
        if OtherPlayer ~= nil then
            local Amount = tonumber(args[2])
            table.remove(args, 1)
            table.remove(args, 1)
            local Reason = table.concat(args, " ")
            TriggerEvent('qb-billing:server:CreateBill', Player, OtherPlayer, Amount, Reason)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_online"), 'error')
        end
    end
end)

QBCore.Commands.Add("unpayedbills", Lang:t("info.unpayed_bills"), {{name="id", help="Player ID"}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player.PlayerData.job.name == Config.VerifyJob then
        if OtherPlayer ~= nil then
            TriggerEvent('qb-billing:server:ShowUnpayedBills', source, OtherPlayer.PlayerData.citizenid)
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_online"), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_correct_job"), 'error')
    end
end)

--Events
--RegisterNetEvent('qb-billing:server:ShowUnpayedBillsFromClient', function(data)
--    local citizenid = data.citizenid
--    TriggerEvent('qb-billing:server:ShowUnpayedBills', source, citizenid)
--end)

RegisterNetEvent('qb-billing:server:ShowUnpayedBills', function(source, citizenid)
    local Player = QBCore.Functions.GetPlayer(source)
    local bills = {}
    exports.oxmysql:execute('SELECT * FROM accounting WHERE customer = ? and status = 0 or status = 2', {citizenid}, function(result)
        for _, bill in pairs(result) do 
            bills[#bills + 1] = {
                Issuer = QBCore.Functions.GetPlayerByCitizenId(bill.issuer),
                Customer = QBCore.Functions.GetPlayerByCitizenId(bill.customer),
                Reference = bill.reference,
                Status = bill.status,
                Amount = bill.amount,
                Reason = bill.reason,
                Date = bill.date,
                Job = bill.job,
            }
        end
        TriggerClientEvent('qb-billing:client:MenuShowBills', source, bills, "Unpayed", 1)
    end)
end)




RegisterNetEvent('qb-billing:server:ShowStatsForCompanyFromClient', function()
    TriggerEvent('qb-billing:server:ShowStatsForCompany', source)
end)
RegisterNetEvent('qb-billing:server:ShowStatsForCompany', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local Employees = {}
    exports.oxmysql:execute('SELECT * FROM accounting WHERE job = ? and status = 1', {Player.PlayerData.job.name}, function(result)
        for _, bill in pairs(result) do 
            if Employees[bill.issuer] then
                Employees[bill.issuer].amount = Employees[bill.issuer].amount + bill.amount
            else
                Employees[bill.issuer] = {
                    amount = bill.amount, 
                    job = bill.job,
                }
            end
        end
        TriggerClientEvent('qb-billing:client:MenuShowStatsCompany', source, Employees)
    end)
end)

RegisterNetEvent('qb-billing:server:ShowStatsForEmployeeFromClient', function(data)
    local citizenid = data.citizenid
    local job = data.job
    TriggerEvent('qb-billing:server:ShowStatsForEmployee', source, citizenid, job)
end)

RegisterNetEvent('qb-billing:server:ShowStatsForEmployee', function(source, citizenid, job)
    local src = source						                    -- Get src from source
    local Player = QBCore.Functions.GetPlayer(src)
    local bills = {}
    exports.oxmysql:execute('SELECT * FROM accounting WHERE issuer = ? and job = ? and status = 1', {citizenid, job}, function(result)
        for _, bill in pairs(result) do 
            bills[#bills + 1] = {
                Issuer = QBCore.Functions.GetPlayerByCitizenId(bill.issuer),
                Customer = QBCore.Functions.GetPlayerByCitizenId(bill.customer),
                Reference = bill.reference,
                Status = bill.status,
                Amount = bill.amount,
                Reason = bill.reason,
                Date = bill.date,
                Job = bill.job,
            }
        end
        if Player.PlayerData.job.isboss then
            TriggerClientEvent('qb-billing:client:MenuShowBills', src, bills, Player.PlayerData.job.label, 2)
        else
            TriggerClientEvent('qb-billing:client:MenuShowBills', src, bills, Player.PlayerData.job.label, 1)
        end
    end)
end)

RegisterNetEvent('qb-billing:server:ShowBillsFromClient', function()
    TriggerEvent('qb-billing:server:ShowBills', source)
end)

RegisterNetEvent('qb-billing:server:ShowBills', function(source)
    local src = source						                    -- Get src from source
    local Player = QBCore.Functions.GetPlayer(src)
    local bills = {}
    exports.oxmysql:execute('SELECT * FROM accounting WHERE job = ? and status = 0 or status = 2', {Player.PlayerData.job.name}, function(result)
        for _, bill in pairs(result) do 
            bills[#bills + 1] = {
                Issuer = QBCore.Functions.GetPlayerByCitizenId(bill.issuer),
                Customer = QBCore.Functions.GetPlayerByCitizenId(bill.customer),
                Reference = bill.reference,
                Status = bill.status,
                Amount = bill.amount,
                Reason = bill.reason,
                Date = bill.date,
                Job = bill.job,
            }
        end
        TriggerClientEvent('qb-billing:client:MenuShowBills', src, bills, Player.PlayerData.job.label, false)
    end)
end)

RegisterNetEvent('qb-billing:server:CreateBill', function(fromPlayer, toPlayer, amount, reason)
    --Prepare data
    local Job = fromPlayer.PlayerData.job.name
    local Reference = Config.Companies[Job].Reference..fromPlayer.PlayerData.citizenid..os.date("%Y%m%d%H%M%S")
    local Date = os.date("%Y%m%d")
    --Create bill inside DB
    exports.oxmysql:insert("INSERT INTO `accounting` (`reference`, `type`, `issuer`, `job`, `customer`, `date`, `status`, `amount`, `reason`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
        Reference,
        'RP',
        fromPlayer.PlayerData.citizenid,
        Job,
        toPlayer.PlayerData.citizenid,
        Date,
        0,
        amount,
        reason
    },
    function(success)
        if success then
            local Bill = {}
            Bill.Issuer = fromPlayer
            Bill.Customer = toPlayer
            Bill.Reference = Reference
            Bill.Status = 0
            Bill.Amount = amount
            Bill.Reason = reason
            Bill.Date = Date
            Bill.Job = Job
            --Send bill to customer
            TriggerClientEvent('qb-billing:client:MenuReceiveBill', toPlayer.PlayerData.source, Bill)
        end
    end)

end)

RegisterNetEvent('qb-billing:server:PayBill', function(bill, company)
    local Player = QBCore.Functions.GetPlayer(bill.Customer.PlayerData.source) 
    local Issuer = bill.Issuer
    local Balance = 0
    --Get balance
    if company then
        Balance = exports['qb-bossmenu']:GetAccount(company)
    else
        Balance = Player.PlayerData.money[Config.Companies[bill.Job].Account]
    end
    Balance = Balance - bill.Amount
    if Balance >= 0 or Config.Companies[bill.Job].Account == "bank" then
        if company then
            --Remove money from company
            TriggerEvent('qb-bossmenu:server:removeAccountMoney', company, bill.Amount)
        else
            --Remove money from customer
            Player.Functions.RemoveMoney(Config.Companies[bill.Job].Account, tonumber(bill.Amount), "Bill")
        end
        --Add money to Company Account
        TriggerEvent('qb-bossmenu:server:addAccountMoney', bill.Job, bill.Amount)
        --Update bill in table
        exports.oxmysql:execute('UPDATE accounting SET status = ? WHERE reference = ?', { "1", bill.Reference })
        --Send notifications
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('success.you_payed', {value = bill.Amount}), 'primary')
        TriggerClientEvent('QBCore:Notify', Issuer.PlayerData.source, Lang:t('success.payed_you', {value = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname, value2 = bill.Amount}), 'primary')
    else
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.not_enough'), 'error')
    end
end)

RegisterNetEvent('qb-billing:server:CancelBill', function(data)
    local src = QBCore.Functions.GetPlayer(source) 
    local bill = data.bill
    exports.oxmysql:execute('DELETE FROM accounting WHERE reference = ?', { bill.Reference })
    local Player = QBCore.Functions.GetPlayer(bill.Customer.PlayerData.source) 
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.bill_cancelled', {value = bill.Reference}), 'primary')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.bill_cancelled', {value = bill.Reference}), 'primary')
    TriggerEvent('qb-billing:server:ShowBills', source)
end)

RegisterNetEvent('qb-billing:server:DunnBill', function(data)
    local costs = data.costs
    local bill = data.bill
    if costs then
        --Add costs to the bill
        bill.Amount = bill.Amount + (bill.Amount / 100 * Config.DunningCost )
        --Save new amount
        exports.oxmysql:execute('UPDATE accounting SET amount = ?, status = ? WHERE reference = ?', { bill.Amount, "2", bill.Reference })
    end
    --Send bill by email
    --local Player = QBCore.Functions.GetPlayer(bill.Customer.PlayerData.source) 
    TriggerClientEvent('qb-billing:client:SendBill', bill.Customer.PlayerData.source, bill)
end)
