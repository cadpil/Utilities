local ItemsStorage = game:GetService("ServerStorage").Items

return {

    ["Potion"] = {
        Animations = {
            Use = "rbxassetid://16568995929"
        }
    };

    [100_001] = {
        Name = "Health Potion";
        Class = "Consumable";
        SubClass = "Potion";
        MaxStack = 6;
        ItemId = 100_001;
        Icon = "rbxassetid://16524238985";
        ModelReference = ItemsStorage.Stick;

        Stats = {
            Time = 2.66;
            Health = 10
        };
        Effects = {};

        Quantity = 0;
        Keybind = 0;
    }

}