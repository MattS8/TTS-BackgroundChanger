--Constants used to dynamically create new background options
cOptionSpacing = 1.2
cOptionHeight = 250
cOptionWidth = 1080
cFirstOptionPosition = {0,0.1,0}
cOptionRotation = {0,90,0}

cMaxOptionsPerMenu = 10

--Global variable that stores all background options.
gAllOptions = {}
gGenericBackgrounds = {Label = '|-> Generic', ParentMenu = gAllOptions, Options = {
    {Label = 'Cathedral', SpawnPosition = {-408.00,51,0}, SpawnRotation = {0,90,0}, Scale = {1.3,1.3,1}, BackgroundModel = "http://cloud-3.steamusercontent.com/ugc/1779463654663911682/38972F9AE804AF72A9DA6CA39FA9F67B72A38A97/" },
    {Label = 'Graveyard', SpawnPosition = {0,-42.48,0}, SpawnRotation = {0,0,0}, Scale = {1,1,1}, BackgroundModel = "http://cloud-3.steamusercontent.com/ugc/1779463654663911451/B312ED868D66321281E16A84F9A3135E54F35FD6/" },
    {Label = 'Cellar', SpawnPosition = {0,-0.7,0}, SpawnRotation = {0,0,0}, Scale = {0.6,0.6,0.6}, BackgroundModel = "http://cloud-3.steamusercontent.com/ugc/1788471001845518733/DCC7DC03A02DA1CBD95651D60FEFE1AC62F5BEEF/" },
    {Label = 'Cabin', SpawnPosition = {0,-42.48,0}, SpawnRotation = {0,-90,0}, Scale = {2.5,2.5,2.5}, BackgroundModel = "http://cloud-3.steamusercontent.com/ugc/1788471001845518398/03BBB4B9D2E2F54A309C57AD22F599CE976F0C04/" },
    {Label = 'Underground Temple', SpawnPosition = {0,-30,0}, SpawnRotation = {0,0,0}, Scale = {4,4,4}, BackgroundModel = "http://cloud-3.steamusercontent.com/ugc/919175209175272737/19A89B6ADD53369F2A70D042638DB601428406B7/", FontSize = 70 }
    }
}
gTavernBackgrounds = {Label='|-> Taverns', ParentMenu = gAllOptions, Options = {
    {Label = 'Witcher Inn', BackgroundURL = "https://i.imgur.com/CQkcp6m.jpeg"},
    {Label = 'Realistic Inn', BackgroundURL = "https://cdnb.artstation.com/p/assets/panos/panos/023/527/349/large/40fc79919bce3c2e.jpg?1579514499"},
    {Label = 'Realistic Inn 2', BackgroundURL = "https://cdnb.artstation.com/p/assets/panos/panos/023/527/365/large/22f9119fd6e22cc2.jpg?1579514557"},
    {Label = 'Plain Tavern', BackgroundURL = "https://cdna.artstation.com/p/assets/panos/panos/006/677/038/large/8ed12d3ee830c836.jpg?1500397788"}
}}

--Global variable that stores all visible buttons.
gOptionsVisible = {}

--Global variable that stores the current menu being displayed.
gCurrentMenu = gAllOptions

--Global variable that stores the parent for the current submenu.
-- If the current menu is not a submenu, this will be nil.
gSubMenuParent = nil

--Global variable that holds the currently loaded in background model.
-- If no bg is loaded in, or the background is a static image, this will be nil.
gCurrentBackgroundObj = nil

--Runs when script first loads, makes menu
function onload(savedState)
    loadNow(savedState)
    if not pcall(loadNow, savedState) then print("Failed to load") end

    gAllOptions.Options = {gGenericBackgrounds, gTavernBackgrounds}
    displayMenu(gCurrentMenu)
end

function loadNow(savedState)
    if savedState == nil or savedState == "" then return end
  
    savedTable = JSON.decode(savedState)
    if savedTable == nil then return end
  
    if savedTable.DynamicBackgroundObj ~= nil then
      gCurrentBackgroundObj = getObjectFromGUID(savedTable.DynamicBackgroundObj)
    else
      print("No room found")
    end
  end

function onSave()
    saved, saveString = pcall(saveNow)
    --print(string.format("SaveString: %s", saveString))
    if saved then return saveString end
    print("Failed to save")
    return nil
end

function saveNow()
    saveState = {}
    if gCurrentBackgroundObj ~= nil then
        saveState.DynamicBackgroundObj = gCurrentBackgroundObj.getGUID()
    end

    return JSON.encode(saveState)
end

function entryClicked(option)
    printToAll("HERE")
    if option.Options ~= nil then
        displayMenu(option)
    elseif option.BackgroundURL ~= nil then
        changeBackgroundURL(option.BackgroundURL)
    elseif option.BackgroundModel ~= nil then
        loadBackgroundModel(option)
    else
        printToAll("Unkown entry...", {1,0,0})
    end
end

function changeBackgroundURL(url)
    removeBackgroundObj()
    
    printToAll("Setting custom background: "..url)
    Backgrounds.setCustomURL(url)
end

function removeBackgroundObj()
    if gCurrentBackgroundObj ~= nil then
        destroyObject(gCurrentBackgroundObj)
        gCurrentBackgroundObj = nil
    end
end

function loadBackgroundModel(option)
    removeBackgroundObj()

    gCurrentBackgroundObj = spawnObject({type='Custom_AssetBundle', position=option.SpawnPosition, rotation=option.SpawnRotation})
    custom = {}
    custom.assetbundle = option.BackgroundModel
    gCurrentBackgroundObj.setCustomObject(custom)
    gCurrentBackgroundObj.setScale(option.Scale)
    gCurrentBackgroundObj.setLock(true)
    gCurrentBackgroundObj.interactable = false
end

function removeVisibleOptions()
    self.clearButtons()
end

function displayMenu(menu)
    removeVisibleOptions()

    --Create back button
    if menu.ParentMenu ~= nil then
        printToAll("Showing Back Button...")
        buttonShowParentMenu = { index='0', label='<- Back', click_function='showParentMenu', function_owner=self,
            position=cFirstOptionPosition, rotation=cOptionRotation, height=cOptionHeight/2, width=cOptionWidth, font_size=100 }
        gSubMenuParent = menu.ParentMenu
        self.createButton(buttonShowParentMenu)
    else
        gSubMenuParent = nil
    end

    gCurrentMenu = menu
    for k, v in ipairs(gCurrentMenu) do
        if (type(v) ~= "table") then
            printToAll("obj "..k.." is "..v.." ("..type(v)..")")
        else
            printToAll("obj "..k.." is "..type(v))
        end
        if (type(v) == "table") then
            for x, z in pairs(v) do
                if (type(z) ~= "table") then
                    printToAll("subObj "..x.." is "..z.." ("..type(z)..")")
                else
                    printToAll("subObj "..x.." is "..type(z))
                end
            end
        end
    end
    --Create submenu options
    for k = #menu.Options, 1, -1 do
        createOptionButton(menu.Options[k], k)
    end
end

function showParentMenu()
    if gSubMenuParent == nil then return end

    displayMenu(gSubMenuParent)
end

function createOptionButton(option, i)
    local fontSize = 100
    if option.FontSize ~= nil then
        fontSize = option.FontSize
    end

    printToAll("Creating button with label "..option.Label.." at position "..i)
    buttonOption = {}
    buttonOption.position = {i*-0.5, 0.1,0}
    buttonOption.rotation = {0,90,0}
    buttonOption.label = option.Label
    buttonOption.width = cOptionWidth
    buttonOption.height = cOptionHeight
    buttonOption.function_owner = self;
    buttonOption.click_function = 'cf_'..i
    if not self.createButton(buttonOption) then
        printToAll("Unable to create button...", {1,0,0})
    else
        printToAll("Created button!")
    end
end

--Click functions: Due to stupid LUA limitations, 10 options per menu
function cf_1()
    --printObj(gCurrentMenu.Options, 5)
    printToAll("cf_1 clicked! "..type(gCurrentMenu.Options[1]))
    for k, v in pairs(gCurrentMenu.Options) do
        if (type(v) ~= "table") then
            printToAll("obj "..k.." is "..v.." ("..type(v)..")")
        end
        if (type(v) == "table") then
            for x, z in pairs(v) do
                if (type(z) ~= "table") then
                    printToAll("subObj "..x.." is "..z.." ("..type(z)..")")
                else
                    printToAll("subObj "..x.." is "..type(z))
                end
            end
        end
    end

    printToAll(" --- ")
    entryClicked(gCurrentMenu.Options[1])
end

function cf_2()
    entryClicked(gCurrentMenu.Options[2])
end

function cf_3()
    entryClicked(gCurrentMenu.Options[3])
end

function cf_4()
    entryClicked(gCurrentMenu.Options[4])
end

function cf_5()
    entryClicked(gCurrentMenu.Options[5])
end

function cf_6()
    entryClicked(gCurrentMenu.Options[6])
end

function cf_7()
    entryClicked(gCurrentMenu.Options[7])
end

function cf_8()
    entryClicked(gCurrentMenu.Options[8])
end

function cf_9()
    entryClicked(gCurrentMenu.Options[9])
end

function cf_10()
    entryClicked(gCurrentMenu.Options[10])
end