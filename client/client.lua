local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-billing:client:AcceptBill', function(data)
    local bill
    local company
    if data.Issuer then
        bill = data
        company = false
    else
        bill = data.bill
        company = data.company
    end
    --print(QBCore.Debug(bill))
    TriggerServerEvent('qb-billing:server:PayBill', bill, company)
end)

RegisterNetEvent('qb-billing:client:SendBill', function(data)
    local bill
    if data.Issuer then
        bill = data
    else
        bill = data.bill
    end
    local FromPerson = bill.Issuer
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = FromPerson.PlayerData.charinfo.firstname.." "..FromPerson.PlayerData.charinfo.lastname,
        subject = "Bill",
        message = Lang:t('info.bill_mail', {value = bill.Amount, value2 = bill.Reason}),
        button = {
            enabled = true,
            buttonEvent = "qb-billing:client:AcceptBill",
            buttonData = bill
        }
    })    
end)

RegisterNetEvent('qb-billing:client:MenuReceiveBill', function(bill)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        local FromPerson = bill.Issuer
        local MenuBill = {
            {
                isMenuHeader = true,
                header = Lang:t('info.bill_value', {value = bill.Job, value2 = bill.Amount}),
                txt = Lang:t('info.pay_immediate', {value = FromPerson.PlayerData.charinfo.firstname.." "..FromPerson.PlayerData.charinfo.lastname, value2 = FromPerson.PlayerData.job.label, value3 = bill.Amount}),
            },
            {
                header = 'Pay immediately',
                txt = 'Pay immediately the bill',
                params = {
                    event = 'qb-billing:client:AcceptBill',
                    args = {
                        company = false,
                        bill = bill
                    }
                }
            },
        }
        if Config.Companies[bill.Job].Can_refuse then
            MenuBill[#MenuBill + 1] = {
                header = 'Pay later',
                txt = 'Pay later the bill (Sent by email)',
                params = {
                    event = 'qb-billing:client:SendBill',
                    args = {
                        bill = bill
                    }
                }
            }
        end
        if PlayerData.job.isboss then
            MenuBill[#MenuBill + 1] = {
                header = 'Pay with company',
                txt = 'Pay immediately with company account',
                params = {
                    event = 'qb-billing:client:AcceptBill',
                    args = {
                        company = PlayerData.job.name,
                        bill = bill
                    }
                }
            }        
        end
        exports['qb-menu']:openMenu(MenuBill)
    end)
end)

RegisterNetEvent('qb-billing:client:MenuShowBills', function(bills, job, stats)
    local Total = 0
    --Dummy header to have entry
    local MenuBills = {
        {
            isMenuHeader = true,
            header = "",
        },
    }
    --Items
    for _, bill in pairs(bills) do 
        Total = Total + bill.Amount
        if stats then                   --Stats are not clickable
            MenuBills[#MenuBills + 1] = {
                isMenuHeader = true,
                header = Lang:t('info.show_bills', {value = bill.Reference}),
                txt = Lang:t('info.show_bills_txt', {value = bill.Date, value2 = bill.Amount, value3 = bill.Customer.PlayerData.charinfo.firstname.." "..bill.Customer.PlayerData.charinfo.lastname}),
            }
        else                            --Open Bills are clickable
            MenuBills[#MenuBills + 1] = {
                header = Lang:t('info.show_bills', {value = bill.Reference}),
                txt = Lang:t('info.show_bills_txt', {value = bill.Date, value2 = bill.Amount, value3 = bill.Customer.PlayerData.charinfo.firstname.." "..bill.Customer.PlayerData.charinfo.lastname}),
                params = {
                    event = 'qb-billing:client:MenuShowBill',
                    args = {
                        bill = bill
                    }
                }
            }
        end
    end
    --Header
    if stats then           
        MenuBills[1] = {
            isMenuHeader = true,
            header = Lang:t('info.total_period', {value = Total}),
        }
        if stats == 2 then
            --Back button for company stats
            MenuBills[#MenuBills + 1] = {
                header = 'Back',
                txt = '',
                params = {
                    isServer = true,
                    event = 'qb-billing:server:ShowStatsForCompanyFromClient',
                }
            }                
        end
    else
        MenuBills[1] = {
            isMenuHeader = true,
            header = Lang:t('info.open_bills', {value = job}),
        }
    end

    exports['qb-menu']:openMenu(MenuBills)
end)

RegisterNetEvent('qb-billing:client:MenuShowBill', function(data)
    local bill
    if data.Issuer then
        bill = data
    else
        bill = data.bill
    end
    local MenuShowBill = {
        {
            isMenuHeader = true,
            header = Lang:t('info.bill_detail', {value = bill.Reference}),
            txt = Lang:t('info.bill_detail_txt', {value = bill.Date, value2 = bill.Customer.PlayerData.charinfo.firstname.." "..bill.Customer.PlayerData.charinfo.lastname, value3 = bill.Amount, value4 = bill.Reason}),
        },
        {
            header = 'Cancell Bill',
            txt = 'Cancel the bill',
            params = {
                isServer = true,
                event = 'qb-billing:server:CancelBill',
                args = {
                    bill = bill
                }
            }
        },
        {
            header = 'Send Reminder',
            txt = 'Send a reminder without costs',
            params = {
                isServer = true,
                event = 'qb-billing:server:DunnBill',
                args = {
                    costs = false,
                    bill = bill
                }
            }
        },
    }
    if bill.Status == "0" then
        MenuShowBill[#MenuShowBill + 1] = {
            header = 'Send Dunning',
            txt = 'Send a reminder with costs',
            params = {
                isServer = true,
                event = 'qb-billing:server:DunnBill',
                args = {
                    costs = true,
                    bill = bill
                }
            }
        }
    end
    MenuShowBill[#MenuShowBill + 1] = {
        header = 'Back',
        txt = '',
        params = {
            isServer = true,
            event = 'qb-billing:server:ShowBillsFromClient',
        }
    }
    exports['qb-menu']:openMenu(MenuShowBill)
end)


RegisterNetEvent('qb-billing:client:MenuShowStatsCompany', function(employees)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        local MenuStatsCompany = {
            {
                isMenuHeader = true,
                header = Lang:t('info.stats_for_company', {value = PlayerData.job.label}),
            },
        }
        for key, employee in pairs(employees) do 
            MenuStatsCompany[#MenuStatsCompany + 1] = {
                header = key,
                txt = Lang:t('info.total_period', {value = employee.amount}),
                params = {
                    isServer = true,
                    event = 'qb-billing:server:ShowStatsForEmployeeFromClient',
                    args = { 
                        citizenid = key,
                        job = employee.job,
                    }
                }
            }
        end
        exports['qb-menu']:openMenu(MenuStatsCompany)
    end)
end)










