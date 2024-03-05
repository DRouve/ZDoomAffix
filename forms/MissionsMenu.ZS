/*
 * SimpleMenu.ZS:
 * This example shows how to make a simple menu with a background, a text label,
 * and a single-texture button.
 * Clicking the button changes the colour of the text label's text to a random
 * colour.
*/

// The menu's command handler.
// This is needed so we can make our menu interactable.
class ZDA_ZF_MissionsMenuHandler : ZDA_ZF_Handler
{
    // The menu this command handler belongs to.
    // We need this to be able to do anything with our menu.
    ZDA_ZF_MissionsMenu link;
    //ZDRPGPlayerHandler playerHandler; 

    // override void buttonClickCommand (ZDA_ZF_Button caller, Name command)
    // {
    //     if(command == "abortMission")
    //         playerHandler.SendNetworkEvent(command);

    //     string commandString = command;
    //     Array <String> commandSplit;
    //     commandString.split(commandSplit, ":");
    //     if(commandSplit[0] ~== "showMission" && commandSplit.Size() > 1)
    //     {
    //         let eHandler = ZDRPGMissionHandler(EventHandler.Find("ZDRPGMissionHandler"));
    //         let missionIndex = commandSplit[1].ToInt();
    //         let mission = eHandler.missions[missionIndex];

    //         let descriptionFrame = ZDA_ZF_Frame(link.mainFrame.elements[0]);
    //         let missionInfoFrame = ZDA_ZF_Frame(descriptionFrame.elements[2]);
    //         let rewardInfoFrame = ZDA_ZF_Frame(descriptionFrame.elements[3]);

    //         let selectMissionLabel = ZDA_ZF_Label(descriptionFrame.elements[1]);
    //         selectMissionLabel.hide();

    //         missionInfoFrame.show();
    //         rewardInfoFrame.show();

    //         let missionType = ZDA_ZF_Label(missionInfoFrame.elements[0]);
    //         let missionAmount = ZDA_ZF_Label(missionInfoFrame.elements[1]);
    //         let missionTarget = ZDA_ZF_Label(missionInfoFrame.elements[2]);

    //         let missionAmountOriginPos = missionAmount.GetPos();
    //         let missionTargetOriginPos = missionTarget.GetPos();

    //         missionTarget.hide();
    //         class<Actor> isActor = (class<Actor>)(mission.Item);
    //         if(isActor)
    //         {
    //             let actorDefaults = GetDefaultByType((class<Actor>)(mission.Item));
    //             missionTarget.SetText("Target : " .. actorDefaults.GetTag());
    //             missionTarget.show();

    //             // if mission has monster or item target and "Target" label is below "Amount" label 
    //             if(missionTarget.GetPosY() > missionAmount.GetPosY())
    //             {
    //                 missionAmount.SetPos(missionTargetOriginPos);
    //                 missionTarget.SetPos(missionAmountOriginPos);
    //             }
    //         }
    //         else if(missionTarget.GetPosY() < missionAmount.GetPosY())
    //         {
    //             // if "Target" label is higher than "Amount" label and mission's Item isn't an actor, i.e. Find Items, Find Secrets etc.
    //             missionAmount.SetPos(missionTargetOriginPos);
    //             missionTarget.SetPos(missionAmountOriginPos);
    //         }

    //         missionType.SetText("Type : " .. mission.Type);
    //         missionAmount.SetText("Amount : " .. mission.Amount);

    //         let rewardXP = ZDA_ZF_Label(rewardInfoFrame.elements[0]);
    //         let rewardRank = ZDA_ZF_Label(rewardInfoFrame.elements[1]);
    //         let rewardCredits = ZDA_ZF_Label(rewardInfoFrame.elements[2]);

    //         rewardXP.SetText("XP : " .. mission.RewardXP);
    //         rewardRank.SetText("Rank : " .. mission.RewardRank);
    //         rewardCredits.SetText("Credits : " .. mission.RewardCredits);

    //         let addMissionButton = ZDA_ZF_Button(descriptionFrame.elements[4]);
    //         let abortMissionButton = ZDA_ZF_Button(descriptionFrame.elements[5]);
            
    //         let missionController = ZDRPGMissionController(players[consoleplayer].mo.FindInventory("ZDRPGMissionController"));

    //         abortMissionButton.hide();
    //         if(missionController.mission)
    //             abortMissionButton.show();

    //         let encodedMission = "Id="..missionIndex.."&Difficulty="..mission.Difficulty.."&Type="..mission.Type.."&Item="..mission.Item.."&Amount="..mission.Amount.."&RewardXP="..mission.RewardXP.."&RewardRank="..mission.RewardRank.."&RewardCredits="..mission.RewardCredits.."&RewardModules="..mission.RewardModules.."&RewardItem="..mission.RewardItem;

    //         descriptionFrame.setDontBlockMouse(true);
    //         missionInfoFrame.setDontBlockMouse(true);
    //         addMissionButton.setCommand('addMission:'.. encodedMission);
    //         addMissionButton.show();
    //     }

    //     if(commandSplit[0] ~== "addMission" && commandSplit.Size() > 1)
    //     {
    //         let missionController = ZDRPGMissionController(players[consoleplayer].mo.FindInventory("ZDRPGMissionController"));
    //         if(missionController.mission)
    //             console.printf("mission already exist");
    //         else
    //         {
    //             // send network even to accept mission
    //             playerHandler.SendNetworkEvent(commandString);

    //             Array <String> paramSplit;
    //             commandString.split(paramSplit, "&");
    //             let difficulty = ZDRPGMissionHandler.GetParameter(paramSplit[1]).ToInt();
    //             let eHandler = ZDRPGMissionHandler(EventHandler.Find("ZDRPGMissionHandler"));
                
    //             //let missionElementFrame = caller.getMaster();
    //             let difficultyPageFrame = ZDA_ZF_Frame(link.mainFrame.elements[difficulty+1]);

    //             // remove accepted mission from missions' array and menu
    //             eHandler.missions[ZDRPGMissionHandler.GetParameter(paramSplit[0]).ToInt()].destroy();

    //             // remove all missions in current frame
    //             for(int i = 0; i < difficultyPageFrame.elements.Size(); i++)
    //             {
    //                 if(difficultyPageFrame.elements[i] is "ZDA_ZF_Frame")
    //                     difficultyPageFrame.elements[i].destroy();
    //             }

    //             // re-add missions again (to refresh grid)
    //             link.createMissionBoxes(difficulty, (1920, 1080), difficultyPageFrame);
    //         }
    //     }

    //     if(commandSplit[0] ~== "getPage" && commandSplit.Size() > 1)
    //     {
    //         let descriptionFrame = ZDA_ZF_Frame(link.mainFrame.elements[0]);
    //         let missionInfoFrame = ZDA_ZF_Frame(descriptionFrame.elements[2]);
    //         let rewardInfoFrame = ZDA_ZF_Frame(descriptionFrame.elements[3]);

    //         missionInfoFrame.hide();
    //         rewardInfoFrame.hide();

    //         let addMissionButton = ZDA_ZF_Button(descriptionFrame.elements[4]);
    //         addMissionButton.hide();

    //         let abortMissionButton = ZDA_ZF_Button(descriptionFrame.elements[5]);
    //         abortMissionButton.hide();

    //         let selectMissionLabel = ZDA_ZF_Label(descriptionFrame.elements[1]);
    //         selectMissionLabel.show();

    //         for(int i = 0; i < link.framesList.Size(); i++)
    //         {
    //             link.framesList[i].hide();
    //         }
    //         link.framesList[commandSplit[1].ToInt()].show();
            
    //     }
    // }
}

class ZDA_ZF_MissionsMenu : ZDA_ZF_GenericMenu
{
    // The menu's command handler.
    // We need a command handler so we can make our menu interactable.
    ZDA_ZF_MissionsMenuHandler handler;

    // A font to use for text.
    Font smallFont;

    // A background image.
    ZDA_ZF_Image background;
    // A simple single-texture button.
    ZDA_ZF_Button aButton;
    // A text label.
    ZDA_ZF_Label aLabel;

    array <ZDA_ZF_Frame> framesList;
    
    array <Inventory> weapons;

    override void Init (Menu parent)
    {
        Vector2 baseRes = (1920, 1080);

        // Call GenericMenu's 'Init' function to do some required initialization.
        Super.Init (parent);
        menuactive = Menu.On;
        // Set our base resolution to 320x200.
        SetBaseResolution (baseRes);

        // Get GZDoom's new options menu smallfont.
        smallFont = OptionFont ();

        // Create an instance of the handler.
        handler = new ('ZDA_ZF_MissionsMenuHandler');
        // Set the handler's "link" pointer to us.
        handler.link = self;

        // Add a background.
        /*background = ZDA_ZF_Image.Create
        (
            // Position
            (0, 0),
            // Size
            (1920, 1080),
            // Image path/name
            "graphics/ZFormsExamples/Panel.png",
            // Alignment options
            ZDA_ZF_Image.AlignType_TopLeft
        );
        // Add the image element into the main frame.
        background.Pack (mainFrame);*/

        // Create the box image's textures.

        // Iterate through the player's inventory to find all of their weapons.
        int labelCount = 0; // We need this to calculate the position of the labels.
        let item = players [consoleplayer].mo.inv;

        while (item != NULL)
        {
            // If the inventory item is a weapon...
            if (item is "Weapon") {
                weapons.Push(item);
            }
            // Set "item" to the next item in the player's inventory.
            item = item.inv;
            // Continue the loop.
            continue;
        }

        createDescriptionBox(baseRes);

        array <int> blocksCount;
        array <int> rowsCount;

        if(weapons.Size() > 0)
        {
            let buttonIdle = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonIdle.png", true);
            let buttonHover = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonHovered.png", false);
            let buttonClick = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonClicked.png", false);
            
            for(int j = 0; j < weapons.Size(); j++)
            {
                let difficultyPageFrame = ZDA_ZF_Frame.create(
                    (0, 0),
                    baseRes
                );
                difficultyPageFrame.setDontBlockMouse(true);
                difficultyPageFrame.pack(mainFrame);

                createMissionBoxes(j, baseRes, difficultyPageFrame);

                // Add a label.
                aLabel = ZDA_ZF_Label.Create
                (
                    // Position
                    (950, 20),
                    // Size.
                    (0, smallFont.GetHeight ()),
                    // The label's text
                    text: weapons[j].GetTag(),
                    // The font to use
                    fnt: smallFont,
                    // Whether to automatically wrap the text or not
                    wrap: false,
                    // Whether to automatically resize the element based on the text width
                    autoSize: true,
                    // The text's colour
                    textColor: Font.CR_WHITE
                );
                // Add the label element to the main frame.
                aLabel.Pack (difficultyPageFrame);

                blocksCount.Clear();
                rowsCount.Clear();
                difficultyPageFrame.hide();
                
                framesList.Push(difficultyPageFrame);
                
            }

            framesList[0].show();
        }
    }

    void createDescriptionBox(Vector2 baseRes)
    {
        int descriptionFrameOffset = 75;

        let descriptionFrame = ZDA_ZF_Frame.create(
            (descriptionFrameOffset, baseRes.y - (baseRes.y * 0.5)),
            (baseRes.x - 2*descriptionFrameOffset, baseRes.y - (baseRes.y * 0.5) - 100)
        );
        descriptionFrame.pack(mainFrame); // index: 0

        let boxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "graphics/ZFormsExamples/BoxTextureGreen.png",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );

        let aBoxImage = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            descriptionFrame.getSize(),
            // Texture
            boxTexture,
            // Scale
            (0.25, 0.25)
        );

        aBoxImage.pack(descriptionFrame); // index: 0

        let descriptionFrameSize = descriptionFrame.getSize();

        // Add a label.
        aLabel = ZDA_ZF_Label.Create
        (
            // Position
            (descriptionFrameSize.x * 0.5 - 50, descriptionFrameSize.y * 0.5 - smallFont.GetHeight()),
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "Select mission",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        aLabel.pack(descriptionFrame); // index: 1

        let missionInfoBox = CreateMissionInfoBox(descriptionFrame);
        let missionRewardBox = CreateMissionRewardBox(descriptionFrame, missionInfoBox);

        missionInfoBox.setDontBlockMouse(true);
        missionRewardBox.setDontBlockMouse(true);

        missionInfoBox.hide();
        missionRewardBox.hide();

        let addMissionButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (descriptionFrameSize.x * 0.5 - 172, descriptionFrameSize.y * 0.75),
            // Size
            (345, 50),
            // Our command handler
            text: "Accept mission",
            cmdHandler: handler,
            // A command string for the button
            command: 'addMission:0',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_GREEN
        );

        // Add the button element into the main frame.
        addMissionButton.Pack (descriptionFrame); // index: 4

        addMissionButton.hide();

        let abortMissionButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (descriptionFrameSize.x * 0.5 - 275, addMissionButton.GetPosY() + bigFont.GetHeight() * 3),
            // Size
            (550, 50),
            // Our command handler
            text: "Abort current mission",
            cmdHandler: handler,
            // A command string for the button
            command: 'abortMission',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_RED
        );

        // Add the button element into the main frame.
        abortMissionButton.Pack (descriptionFrame); // index: 5

        abortMissionButton.hide();

        
    }

    ZDA_ZF_Frame CreateMissionInfoBox(ZDA_ZF_Frame descriptionFrame)
    {
        int descriptionFrameOffset = 75;
        let descriptionFrameSize = descriptionFrame.getSize();

        let missionInfoFrame = ZDA_ZF_Frame.create(
            (40, 40),
            (descriptionFrameSize.x - (descriptionFrameSize.x * 0.5) - 60, descriptionFrameSize.y - descriptionFrameOffset - 40)
        );
        missionInfoFrame.pack(descriptionFrame); // index: 2

        let missionInfoBoxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "graphics/ZFormsExamples/BoxTextureBlue.png",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );

        let missionInfoBox = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            missionInfoFrame.getSize(),
            // Texture
            missionInfoBoxTexture,
            // Scale
            (0.25, 0.25)
        );

        //missionInfoBox.pack(missionInfoFrame); // index: 0

        // Add a label.
        let missionType = ZDA_ZF_Label.Create
        (
            // Position
            (75, 75),
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        missionType.pack(missionInfoFrame); // index: 0

        // Add a label.
        let missionAmount = ZDA_ZF_Label.Create
        (
            // Position
            (missionType.GetPosX(), missionType.GetPosY() + smallFont.GetHeight() * 2), 
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        missionAmount.pack(missionInfoFrame); // index: 1

        // Add a label.
        let missionTarget = ZDA_ZF_Label.Create
        (
            // Position
            (missionAmount.GetPosX(), missionAmount.GetPosY() + smallFont.GetHeight() * 2), 
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        missionTarget.pack(missionInfoFrame); // index: 2
        //missionTarget.hide();

        return missionInfoFrame;
    }

    ZDA_ZF_Frame CreateMissionRewardBox(ZDA_ZF_Frame descriptionFrame, ZDA_ZF_Frame missionInfoFrame)
    {
        int descriptionFrameOffset = 75;
        let descriptionFrameSize = descriptionFrame.getSize();
        let missionInfoFrameSize = missionInfoFrame.getSize();

        let missionInfoFrame = ZDA_ZF_Frame.create(
            (missionInfoFrameSize.x + 60, 40),
            (descriptionFrameSize.x - (descriptionFrameSize.x * 0.5) - 40, descriptionFrameSize.y - descriptionFrameOffset - 40)
        );
        missionInfoFrame.pack(descriptionFrame); // index: 3

        let missionInfoBoxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "graphics/ZFormsExamples/BoxTextureRed.png",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );

        let missionInfoBox = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            missionInfoFrame.getSize(),
            // Texture
            missionInfoBoxTexture,
            // Scale
            (0.25, 0.25)
        );

        //missionInfoBox.pack(missionInfoFrame); // index: 0

        // Add a label.
        let rewardXP = ZDA_ZF_Label.Create
        (
            // Position
            (75, 75),
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "XP : 10000",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        rewardXP.pack(missionInfoFrame); // index: 1

        // Add a label.
        let rewardRank = ZDA_ZF_Label.Create
        (
            // Position
            (rewardXP.GetPosX(), rewardXP.GetPosY() + smallFont.GetHeight() * 2), 
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "Rank : 5000",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        rewardRank.pack(missionInfoFrame); // index: 2

        // Add a label.
        let rewardCredits = ZDA_ZF_Label.Create
        (
            // Position
            (rewardRank.GetPosX(), rewardRank.GetPosY() + smallFont.GetHeight() * 2), 
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "Credits : 750",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        rewardCredits.pack(missionInfoFrame); // index: 3

        return missionInfoFrame;
    }

    void createMissionBoxes(int difficulty, Vector2 baseRes, ZDA_ZF_Frame difficultyPageFrame)
    {
        array <int> blocksCount;
        array <int> rowsCount;

        for(int i=0; i<30; i++)
        {
            CreateStatBox(baseRes, blocksCount, rowsCount, difficultyPageFrame);
        }
    }

    void CreateStatBox(Vector2 baseRes, out array <int> blocksCount, out array <int> rowsCount, ZDA_ZF_Frame frame) 
    {
        
        let boxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "graphics/ZFormsExamples/BoxTextureGreen.png",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );

        let offsetY = 500;
        // Add a box image.
        let boxSize = (88, 88);
        if((50 + boxSize.X) * blocksCount.Size() > baseRes.X)
        {
            blocksCount.Clear();
            rowsCount.Push(1);
        }
        let boxOffset = offsetY + boxSize.X * blocksCount.Size() - (blocksCount.Size() * 10);
        let boxInnerOffset = 0;

        let buttonFrame = ZDA_ZF_Frame.create(
            (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
            boxSize
        );

        buttonFrame.pack(frame);

        background = ZDA_ZF_Image.Create
        (
            // Position
            (0, 0),
            // Size
            (88, 88),
            // Image path/name
            "graphics/bbs/MISSBOXB3.png",
            // Alignment options
            ZDA_ZF_Image.AlignType_TopLeft,
            (2, 2)
        );
        // Add the image element into the main frame.
        background.Pack (buttonFrame);

        /*let aBoxImage = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            boxSize,
            // Texture
            boxTexture,
            // Scale
            (0.25, 0.25)
        );
        // Add the box image element into the main frame.
        aBoxImage.Pack (buttonFrame);*/

        // Create the button's textures.
        let buttonIdle = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonIdle.png", true);
        let buttonHover = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonHovered.png", false);
        let buttonClick = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonClicked.png", false);

        let buttonSideSize = 88;
        let buttonPosX = boxOffset + boxInnerOffset + background.GetWidth() / 2 - buttonSideSize / 2;
        let buttonPosY = offsetY + (rowsCount.Size() * (boxSize.X + 32)) + background.GetHeight() / 2 - buttonSideSize / 2;

        // Add a button.
        aButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (0, 0),
            // Size
            (buttonSideSize, buttonSideSize),
            // Our command handler
            cmdHandler: handler,
            // A command string for the button
            command: "zzz"
            // The button's textures
            //inactive: buttonIdle,
            //hover: buttonHover,
            //click: buttonClick
        );
        // Add the button element into the main frame.
        aButton.Pack (buttonFrame);

        blocksCount.Push(1);
    }
}
