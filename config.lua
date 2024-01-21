Config = {}
Config.Core = 'qb' -- qb / esx

Config.Locations = {
    ['MainDesk'] = {vector3(72.975 , -1454.90 , 29.29)},
    ['Shop'] = {vector3(74.175 , -1455.99 , 29.27)},
    ['Boss'] = {vector3(57.4285 , -1445.828 , 29.34)},

    ['HairChairs'] = {
        {chairID = 1 , coords = vector3(68.835 , -1453.476 , 30.1421)},
        {chairID = 2 , coords = vector3(67.320 , -1452.143 , 30.1054)},
        {chairID = 3 , coords = vector3(65.7779, -1450.7806, 30.1521)},
        {chairID = 4 , coords = vector3(64.2880, -1449.5569, 30.1873)},
    },

    ['NailChairs'] = {
        {chairID = 5 , coords = vector3(64.8305, -1443.5645, 29.9852) , camCoords = vector4(64.6634, -1442.0924, 32.4034, 184.7257)},
        {chairID = 6 , coords = vector4(67.5374, -1442.0409, 29.9852 ,  48.4341) , camCoords = vector4(66.2841, -1441.3711, 32.4034, 228.9814)},
        
    }

}

Config.Nails = {
    [1] = {CategoryID = 1 , ClothID = 15 }, -- 1: Face 2: Mask 3: Hair 4: Torso 5: Legs 6: Parachute / Bag 7: Shoes 8: Accessory 9: Undershirt 10: Kevlar 11: Badge 12: Torso 2 13: Head 14: Glasses 15: Ear Accessory 16: Watch 17: Bracelet 18: Top 19: Armor 20: Decals 21: APU / Scuba Tank 22: Holster 23: Shirt 24: Pants 25: Bag 26: Ties & Scarves 27: Armor 2 28: Torso 3 29: Leg 2 30: Kevlar 2 31: Badge 2 32: Decals 2 33: Top 2 34: Armor 3 35: Top 3 36: Leg 3 37: Shoes 2 38: Accessory 2 39: Undershirt 2 40: Kevlar 3 41: Badge 3 42: Top 4 43: Leg 4 44: Undershirt 3 45: Shoes 3 46: Accessory 3 47: Top 5 48: Leg 5 49: Undershirt 4 50: Shoes 4 51: Accessory 4 52: Arms
    [2] = {CategoryID = 1 , ClothID = 14 }, 
    [3] = {CategoryID = 1 , ClothID = 16 }, 

}

Config.RequiredItemsNpc = {
    ['Npc'] = {
        Model = 'a_f_m_bevhills_01' , 
        Coords = vector4(56.9422, -1438.1359, 29.3453, 233.3652),
    } , 
    ['Items'] = {
        {name = 'nailpolish' , label = 'Nail Polish', price = 100},
        {name = 'cotton' , label = 'Cotton' , price = 200},
        {name = 'clippers' , label = 'Nail Clipper', price = 40},
        {name = 'nailfile' , label = 'Nail File', price = 500},
		{name = 'remover' , label = 'Remover', price = 500},
		{name = 'topcoat' , label = 'Top Coat', price = 500},
		{name = 'peruvien' , label = 'Peruvien Bundle', price = 500},
        {name = 'brazilian' , label = 'Brazilian Bundle', price = 300},
		{name = 'vietnamese' , label = 'Vietnamese Bundle', price = 500},
    }
}

Config.RareItem = 'boophone' -- RARE ITEM TO RESELL AT HIGHER PRICE using /fsale
-- 
Config.Required = { -- CREATE CRAFTING ALLOWING WORKERS TO MAKE THE REQUIRED ITEMS FOR THE SHOP NAIL POLISH AS EXAMPLE
    ['nailpolish'] = {
        ItemsRequired = {{name = 'pigment', coords = vector3(0 , 0 , 0)},
                   		 {name = 'solvent', coords = vector3(0 , 0 , 0)},
						 {name = 'polymers', coords = vector3(0 , 0 , 0)}},
        ProcessCoords = vector3(0 , 0 , 0),
        RareItemChance = 0.01, -- CHANCE OF RARE ITEM 1/100
    }
}

Config.Prices = {
    ['Nails'] = 100,
    ['Hair'] = 100,
    ['both'] = 180,

}

Config.Support = {
    ['Text'] = '',
    ['Number'] = '',
    ['Image'] = '',
}

Config.MenuCommands = {
    ['NailsMenu'] = 'Nails',
    ['HairMenu'] = 'applyHair',
    ['BookedList'] = 'Booked',
}

Config.BusinessTargets = {
    ['Sales'] = 5,
    ['AvgMade'] = 1400 , 
    ['CheckedIN'] = 1000,
    ['WeekMoney'] = 750,

}

Config.ShopItems = {
    ['nailpolish'] = {
        label = 'Nail Polish',
        price = 100, 
        itemImage = 'https://media.discordapp.net/attachments/1125530388010377286/1161280242611146893/d.png'
    },
}


--[THIS PART IS FOR THE SELLING THE ITEMS THEY PURCHASE FROM Config.RequiredItemsNpc USING /fsale IN GAME ]

-- what inventory do you use?
Config.Inventory = 'qb' -- 'qb', 'ps', 'ox'


Config.Debug= true 


-- what target do you use?
Config.Target = 'qb' -- 'qb', 'ox' (false: DrawText3D)

-- what radial menu do you use?
Config.Radial = 'qb' -- 'qb', 'ox'

-- what dispatch to use for police alerts?
Config.Dispatch = 'qb' -- 'qb', 'ps', 'moz', 'cd', 'custom'

-- what menu you want to use?
Config.OxMenu = true -- true: Ox Menu, false: Ox Context Menu

-- Minimum cops required to sell items
Config.MinimumCops = 0

-- Give bonus on selling when no of cops are online
Config.GiveBonusOnPolice = false

-- Allow selling to peds sitting in vehicle
Config.SellPedOnVehicle = false

-- Chance to sell 
Config.ChanceSell = 70 -- (in %) 

-- Random sell amount
Config.RandomSell = { min = 1, max = 6 } -- range: min, max

-- Selling timeout so that the menu doesnt stay forever
Config.SellTimeout = 10 -- (secs) Max time you get to choose your option

-- The below option decides whether the person has to toggle selling in a zone (radialmenu/command) (Recommended: false)
Config.ShouldToggleSelling = true

-- Ped models that you dont want to be sold to
Config.BlacklistPeds = {
    "mp_m_shopkeep_01",
    "s_m_y_ammucity_01",
    "s_m_m_lathandy_01",
    "s_f_y_clubbar_01",
    "ig_talcc",
    "g_f_y_vagos_01",
    "hc_hacker",
    "s_m_m_migrant_01",
}

-- The below option is for you to enable selling anywhere
Config.SellAnywhere = false

-- SellItems to be configured only if [Config.SellAnywhere = true]
Config.SellItems = {
    { item = 'vietnamese',    price = math.random(100, 200) },
    { item = 'brazilian', price = math.random(100, 200) },
    { item = 'peruvien',         price = math.random(100, 200) },
}

-- SellZones will only if [Config.SellAnywhere = false]
Config.SellZones = { -- Sell zones and their items
    ['groove'] = {
        points = {
            vec3(251.0, -1860.0, 27.0),
            vec3(139.0, -1997.0, 27.0),
            vec3(132.0, -2025.0, 27.0),
            vec3(91.0, -2023.0, 27.0),
            vec3(-151.0, -1788.0, 27.0),
            vec3(-110.0, -1751.0, 27.0),
            vec3(42.0, -1688.0, 27.0),
            vec3(60.0, -1699.0, 27.0),
        },
        thickness = 60.0,
        items = {
            { item = 'vietnamese',    price = math.random(100, 200) },
            { item = 'brazilian', price = math.random(100, 200) },
            { item = 'peruvien',         price = math.random(100, 200) },
        }
    },
    ['vinewood'] = {
        points = {
            vec3(-663.80639648438, 114.2766418457, 97.0),
            vec3(-660.09497070312, 299.65426635742, 97.0),
            vec3(-546.58837890625, 275.86111450196, 97.0),
            vec3(-542.21002197266, 357.8136291504, 97.0),
            vec3(-519.6430053711, 349.90490722656, 97.0),
            vec3(-512.67572021484, 276.3483581543, 97.0),
            vec3(21.216751098632, 278.6813659668, 97.0),
            vec3(49.785594940186, 339.29946899414, 97.0),
            vec3(108.84923553466, 399.87518310546, 97.0),
            vec3(124.068069458, 384.4684753418, 97.0),
            vec3(92.195236206054, 354.55239868164, 97.0),
            vec3(170.3550567627, 377.32186889648, 97.0),
            vec3(841.11456298828, 199.74020385742, 97.0),
            vec3(530.7640991211, -193.10136413574, 97.0)
        },
        thickness = 80.0,
        items = {
            { item = 'vietnamese',    price = math.random(100, 200) },
            { item = 'brazilian', price = math.random(100, 200) },
            { item = 'peruvien',         price = math.random(100, 200) },
        }
    },
    ['forumdr'] = {
        points = {
            vec3(-181.78276062012, -1767.562133789, 32.0),
            vec3(-232.15049743652, -1728.5841064454, 32.0),
            vec3(-257.00219726562, -1706.3781738282, 32.0),
            vec3(-316.23831176758, -1670.7681884766, 32.0),
            vec3(-317.6089477539, -1671.6815185546, 32.0),
            vec3(-339.08483886718, -1659.1655273438, 32.0),
            vec3(-345.54052734375, -1655.4389648438, 32.0),
            vec3(-370.05755615234, -1640.6751708984, 32.0),
            vec3(-357.4814453125, -1617.630859375, 32.0),
            vec3(-344.98095703125, -1605.980834961, 32.0),
            vec3(-308.92208862304, -1544.8927001954, 32.0),
            vec3(-304.6683959961, -1535.6296386718, 32.0),
            vec3(-307.36282348632, -1531.2420654296, 32.0),
            vec3(-303.91906738282, -1514.8071289062, 32.0),
            vec3(-302.4489440918, -1508.5216064454, 32.0),
            vec3(-299.51068115234, -1489.9995117188, 32.0),
            vec3(-297.42388916016, -1452.6616210938, 32.0),
            vec3(-297.9144897461, -1445.0788574218, 32.0),
            vec3(-300.47821044922, -1410.740600586, 32.0),
            vec3(-243.52647399902, -1409.9093017578, 32.0),
            vec3(-228.14682006836, -1408.454711914, 32.0),
            vec3(-214.2696685791, -1404.2430419922, 32.0),
            vec3(-202.69938659668, -1398.415649414, 32.0),
            vec3(-176.32830810546, -1382.9993896484, 32.0),
            vec3(-140.07070922852, -1360.1298828125, 32.0),
            vec3(-131.92518615722, -1353.8952636718, 32.0),
            vec3(-126.67826080322, -1347.0697021484, 32.0),
            vec3(-122.79215240478, -1338.1767578125, 32.0),
            vec3(-122.24575042724, -1335.2940673828, 32.0),
            vec3(-88.574974060058, -1337.8919677734, 32.0),
            vec3(-83.885818481446, -1337.3891601562, 32.0),
            vec3(-72.32137298584, -1347.8657226562, 32.0),
            vec3(-55.457233428956, -1349.6873779296, 32.0),
            vec3(-46.141300201416, -1350.8635253906, 32.0),
            vec3(0.30536636710166, -1350.3518066406, 32.0),
            vec3(19.377029418946, -1349.9018554688, 32.0),
            vec3(46.155563354492, -1350.2407226562, 32.0),
            vec3(56.231525421142, -1346.1237792968, 32.0),
            vec3(61.976043701172, -1336.847290039, 32.0),
            vec3(61.876712799072, -1331.4219970704, 32.0),
            vec3(94.016792297364, -1317.3137207032, 32.0),
            vec3(98.473731994628, -1315.1446533204, 32.0),
            vec3(100.91152191162, -1318.8972167968, 32.0),
            vec3(116.59771728516, -1309.0223388672, 32.0),
            vec3(115.354637146, -1306.6965332032, 32.0),
            vec3(142.13439941406, -1291.261352539, 32.0),
            vec3(143.9640197754, -1293.9191894532, 32.0),
            vec3(159.81324768066, -1280.7825927734, 32.0),
            vec3(166.5573272705, -1270.3135986328, 32.0),
            vec3(203.52110290528, -1282.7435302734, 32.0),
            vec3(231.76536560058, -1329.863647461, 32.0),
            vec3(215.84732055664, -1346.2076416016, 32.0),
            vec3(190.12483215332, -1387.3775634766, 32.0),
            vec3(162.40365600586, -1423.5834960938, 32.0),
            vec3(154.98637390136, -1424.7723388672, 32.0),
            vec3(126.23979187012, -1458.2556152344, 32.0),
            vec3(108.94204711914, -1478.851196289, 32.0),
            vec3(113.4779586792, -1482.6186523438, 32.0),
            vec3(111.75213623046, -1484.7049560546, 32.0),
            vec3(109.91118621826, -1483.4962158204, 32.0),
            vec3(92.817611694336, -1503.7390136718, 32.0),
            vec3(69.58283996582, -1526.8861083984, 32.0),
            vec3(39.489440917968, -1562.9592285156, 32.0),
            vec3(16.217784881592, -1590.7109375, 32.0),
            vec3(0.90857058763504, -1609.6218261718, 32.0),
            vec3(-22.47274017334, -1636.7037353516, 32.0),
            vec3(-65.98893737793, -1687.4913330078, 32.0)

        },
        thickness = 60.0,
        items = {
            { item = 'vietnamese',    price = math.random(100, 200) },
            { item = 'brazilian', price = math.random(100, 200) },
            { item = 'peruvien',         price = math.random(100, 200) },
        }
    }
}