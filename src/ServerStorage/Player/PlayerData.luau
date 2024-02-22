local PlayerData = {}

PlayerData.Default = {
    UserId = 0,

    HotbarMaximum = 10;
    BackpackMaximum = 20;
    Inventory = {
        Hotbar = {
            [1] = {
                ItemId = 100_001;
                Quantity = 1;
                Keybind = 1;
            }
        },
        Backpack = {}
    }
}

PlayerData.Data = {}

return PlayerData