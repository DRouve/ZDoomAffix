/*
 * SimpleMenu.ZS:
 * This example shows how to make a simple menu with a background, a text label,
 * and a single-texture button.
 * Clicking the button changes the colour of the text label's text to a random
 * colour.
*/

// The menu's command handler.
// This is needed so we can make our menu interactable.
class ZDA_ZF_SkillsMenuHandler : ZDA_ZF_Handler
{
    // The menu this command handler belongs to.
    // We need this to be able to do anything with our menu.
    ZDA_ZF_SkillsMenu link;
    ZDRPGPlayerHandler playerHandler; 

    override void buttonClickCommand (ZDA_ZF_Button caller, Name command)
    {
        string commandString = command;
        Array <String> commandSplit;
        commandString.split(commandSplit, ":");

        if(commandSplit[0] ~== "useSkill" && commandSplit.Size() > 1)
        {
            link.mParentMenu.Close();
            playerHandler.SendNetworkEvent(commandString);
        }

        if((commandSplit[0] ~== "upgradeSkill" || commandSplit[0] ~== "increaseSkillLevel" || commandSplit[0] ~== "decreaseSkillLevel") && commandSplit.Size() > 1)
        {
            playerHandler.SendNetworkEvent(commandString);
            let descriptionFrame = ZDA_ZF_Frame(link.mainFrame.elements[0]);
            let upgradeSkillButton = ZDA_ZF_Button(descriptionFrame.elements[3]);
            buttonClickCommand(upgradeSkillButton, "selectSkill:"..commandSplit[1]);
        }

        if(commandSplit[0] ~== "filterSkills" && commandSplit.Size() > 1)
        {
            let skillsFrame = ZDA_ZF_Frame(link.mainFrame.elements[2]);
            // remove all skills
            for(int i = 0; i < skillsFrame.elements.Size(); i++)
                if(skillsFrame.elements[i])
                    skillsFrame.elements[i].destroy();

            let staticHandler = ZDRPGStaticHandler(StaticEventHandler.Find("ZDRPGStaticHandler"));

            link.listItems(staticHandler.skills, link.baseRes, skillsFrame, commandSplit[1]);
        }

        if(commandSplit[0] ~== "selectSkill" && commandSplit.Size() > 1)
        {
            let skillClassName = commandSplit[1];
            let Skill = ZDRPGSkill(players[consoleplayer].mo.FindInventory(skillClassName));

            let descriptionFrame = ZDA_ZF_Frame(link.mainFrame.elements[0]);
            let skillInfoFrame = ZDA_ZF_SkillDescriptionFrame(descriptionFrame.elements[2]);
            let listFrame = ZDA_ZF_Frame(skillInfoFrame.elements[0]);

            let selectSkillLabel = ZDA_ZF_Label(descriptionFrame.elements[1]);
            selectSkillLabel.hide();

            skillInfoFrame.show();

            let skillName        = ZDA_ZF_Label(listFrame.elements[0]);
            skillName.SetText(Skill.GetTag());

            let upgradeSkillButton = ZDA_ZF_Button(descriptionFrame.elements[3]);
            upgradeSkillButton.setCommand("upgradeSkill:".. skillClassName);
            upgradeSkillButton.show();

            let useSkillButton = ZDA_ZF_Button(descriptionFrame.elements[4]);
            useSkillButton.setCommand("useSkill:".. skillClassName);

            let increaseSkillLevelButton = ZDA_ZF_Button(descriptionFrame.elements[5]);
            increaseSkillLevelButton.setCommand("increaseSkillLevel:".. skillClassName);
            increaseSkillLevelButton.show();

            let decreaseSkillLevelButton = ZDA_ZF_Button(descriptionFrame.elements[6]);
            decreaseSkillLevelButton.setCommand("decreaseSkillLevel:".. skillClassName);
            decreaseSkillLevelButton.show();

            skillInfoFrame.EPCostLabel                  = ZDA_ZF_Label(listFrame.elements[1]);
            skillInfoFrame.ModulesCostLabel             = ZDA_ZF_Label(listFrame.elements[2]);
            skillInfoFrame.SkillLevelLabel              = ZDA_ZF_Label(listFrame.elements[3]);
            skillInfoFrame.UpgradeSkillButton           = upgradeSkillButton;
            skillInfoFrame.UseSkillButton               = useSkillButton;
            skillInfoFrame.IncreaseSkillLevelButton     = increaseSkillLevelButton;
            skillInfoFrame.DecreaseSkillLevelButton     = decreaseSkillLevelButton;
            skillInfoFrame.Skill = Skill;
        }
    }
}

class ZDA_ZF_SkillsMenu : ZDA_ZF_GenericMenu
{
    // The menu's command handler.
    // We need a command handler so we can make our menu interactable.
    ZDA_ZF_SkillsMenuHandler handler;

    // A font to use for text.
    Font smallFont;

    // A background image.
    ZDA_ZF_Image background;
    // A simple single-texture button.
    ZDA_ZF_Button aButton;
    // A text label.
    ZDA_ZF_Label aLabel;

    Vector2 baseRes;

    override void Init (Menu parent)
    {
        baseRes = (1920, 1080);

        // Call GenericMenu's 'Init' function to do some required initialization.
        Super.Init (parent);
        //menuactive = Menu.On;
        // Set our base resolution to 320x200.
        SetBaseResolution (baseRes);

        // Get GZDoom's new options menu smallfont.
        smallFont = OptionFont ();

        // Create an instance of the handler.
        handler = new ('ZDA_ZF_SkillsMenuHandler');
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

        /*array< class<ZDRPGSkill> > Skills;
        BuildSkillItemList(Skills);
        for (int i=0; i<Skills.size(); i++) {
            let Skill = ZDRPGSkill(Skills[i]);
            console.printf("skill+: %s", Skill.getClassname());
        }*/

        createDescriptionBox(baseRes);

        array <int> blocksCount;
        array <int> rowsCount;

        array <int> skillsCount;
        array <int> categoriesCount;

        let staticHandler = ZDRPGStaticHandler(StaticEventHandler.Find("ZDRPGStaticHandler"));

        let categoriesFrame = ZDA_ZF_Frame.create(
                (0, 0),
                baseRes
            );
        categoriesFrame.setDontBlockMouse(true);
        categoriesFrame.pack(mainFrame); // index: 1

        // add "All" category
        CreateCategoryBox("All", "filterSkills:", baseRes, categoriesCount, Font.CR_WHITE, categoriesFrame);

        for(int i = 0; i < staticHandler.skillCategories.Size(); i++)
        {
            let skillCategory = GetDefaultByType( (class<ZDRPGSkill>) (staticHandler.skillCategories[i]) );
            CreateCategoryBox(skillCategory.GetTag(), "filterSkills:"..skillCategory.GetClassName(), baseRes, categoriesCount, skillCategory.FontColor, categoriesFrame);
        }

        if(staticHandler.skills.Size() > 0)
        {
            let skillsFrame = ZDA_ZF_Frame.create(
                (0, 0),
                baseRes
            );
            skillsFrame.setDontBlockMouse(true);
            skillsFrame.pack(mainFrame); // index: 2

            listItems(staticHandler.skills, baseRes, skillsFrame);
        }
    }

    void listItems(array <string> itemsArray, Vector2 baseRes, ZDA_ZF_Frame frame, string filter = "")
    {
        array <int> blocksCount;
        array <int> rowsCount;

        for(int i=0; i < itemsArray.Size(); i++)
        {
            let itemDefaults = GetDefaultByType((class<Actor>)(itemsArray[i]));
            let skill = ZDRPGSkill(itemDefaults);

            if(filter && skill.GetParentClass().GetClassName() != filter) 
                continue;

            let itemSprite = skill.Icon;
            //console.printf(itemSprite);
            string cmd = "selectSkill:"..itemsArray[i];
            
            CreateStatBox("", cmd, itemSprite, baseRes, blocksCount, rowsCount, frame);
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
        let selectSkillLabel = ZDA_ZF_Label.Create
        (
            // Position
            (descriptionFrameSize.x * 0.5 - 50, descriptionFrameSize.y * 0.5 - smallFont.GetHeight()),
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: "Select skill",
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );

        selectSkillLabel.pack(descriptionFrame); // index: 1

        let skillInfoBox = CreateSkillInfoBox(descriptionFrame);
        //let shieldRewardBox = CreateMissionRewardBox(descriptionFrame, missionInfoBox);

        skillInfoBox.setDontBlockMouse(true);
        //missionRewardBox.setDontBlockMouse(true);

        skillInfoBox.hide();
        //missionRewardBox.hide();

        let upgradeSkillButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (descriptionFrameSize.x * 0.5 - 172, descriptionFrameSize.y * 0.75),
            // Size
            (345, 50),
            // Our command handler
            text: "Learn",
            cmdHandler: handler,
            // A command string for the button
            command: '',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_GREEN
        );

        // Add the button element into the main frame.
        upgradeSkillButton.Pack (descriptionFrame); // index: 3

        upgradeSkillButton.hide();

        let useSkillButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (descriptionFrameSize.x * 0.5 - 275, upgradeSkillButton.GetPosY() + bigFont.GetHeight() * 3),
            // Size
            (550, 50),
            // Our command handler
            text: "Use",
            cmdHandler: handler,
            // A command string for the button
            command: '',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_GREEN
        );

        // Add the button element into the main frame.
        useSkillButton.Pack (descriptionFrame); // index: 4

        useSkillButton.hide();

        let increaseCurrentLevel = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (230, 268), 
            // Size
            (40, 40),
            // Our command handler
            text: ">",
            cmdHandler: handler,
            // A command string for the button
            command: '',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_GREEN
        );

        // Add the button element into the main frame.
        increaseCurrentLevel.pack(descriptionFrame); // index: 5

        increaseCurrentLevel.hide();

        let decreaseCurrentLevel = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (60, 268), 
            // Size
            (40, 40),
            // Our command handler
            text: "<",
            cmdHandler: handler,
            // A command string for the button
            command: '',
            fnt: bigFont,
            textScale: 2,
            textColor: Font.CR_GREEN
        );

        // Add the button element into the main frame.
        decreaseCurrentLevel.pack(descriptionFrame); // index: 6

        decreaseCurrentLevel.hide();
    }

    ZDA_ZF_Frame CreateSkillInfoBox(ZDA_ZF_Frame descriptionFrame)
    {
        int descriptionFrameOffset = 75;
        let descriptionFrameSize = descriptionFrame.getSize();

        let skillInfoFrame = ZDA_ZF_SkillDescriptionFrame.create(
            (40, 40),
            (descriptionFrameSize.x - (descriptionFrameSize.x * 0.5) - 60, descriptionFrameSize.y - descriptionFrameOffset - 40)
        );
        skillInfoFrame.pack(descriptionFrame); // index: 2

        let skillInfoBoxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
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

        let skillInfoBox = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            skillInfoFrame.getSize(),
            // Texture
            skillInfoBoxTexture,
            // Scale
            (0.25, 0.25)
        );

        //missionInfoBox.pack(missionInfoFrame); // index: 0

        let listFrame = ZDA_ZF_ListFrame.Create
        (
            (75, 75),
            (200, 200),
            smallFont.GetHeight() * 2
        );

        listFrame.pack(skillInfoFrame); // index: 0

        // Add a label.
        let skillName = ZDA_ZF_Label.Create
        (
            // Position
            (0, 0),
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

        skillName.pack(listFrame); // index: 0

        // Add a label.
        let skillEPCost = ZDA_ZF_SkillLabel.Create
        (
            // Position
            (0, 0), 
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

        skillEPCost.pack(listFrame); // index: 1

        // Add a label.
        let skillModulesCost = ZDA_ZF_SkillLabel.Create
        (
            // Position
            (0,0), 
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

        skillModulesCost.pack(listFrame); // index: 2

        // Add a label.
        let skillLevel = ZDA_ZF_Label.Create
        (
            // Position
            (0,0), 
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

        skillLevel.pack(listFrame); // index: 3
        //missionTarget.hide();

        return skillInfoFrame;
    }

    void CreateStatBox(string labelText, string commandName, string img, Vector2 baseRes, out array <int> blocksCount, out array <int> rowsCount, ZDA_ZF_Frame frame) 
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

        let offsetY = 75;
        // Add a box image.
        let boxSize = (72, 72);
        if((50 + boxSize.X) * blocksCount.Size() > baseRes.X - 300)
        {
            blocksCount.Clear();
            rowsCount.Push(1);
        }
        let boxOffset = 335 + boxSize.X * blocksCount.Size();
        let boxInnerOffset = blocksCount.Size() * 32;

        let buttonFrame = ZDA_ZF_Frame.create(
            (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X + 32))),
            boxSize
        );

        buttonFrame.pack(frame);

        background = ZDA_ZF_Image.Create
        (
            // Position
            (0, 0),
            // Size
            boxSize,
            // Image path/name
            "graphics/skills/"..img,
            // Alignment options
            ZDA_ZF_Image.AlignType_TopLeft,
            (1, 1)
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

        let buttonSideSize = 96;
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
            command: commandName
            // The button's textures
            //inactive: buttonIdle,
            //hover: buttonHover,
            //click: buttonClick
        );
        // Add the button element into the main frame.
        aButton.Pack (buttonFrame);

        // Add a label.
        aLabel = ZDA_ZF_Label.Create
        (
            // Position
            (0, 0),
            // Size.
            (0, smallFont.GetHeight ()),
            // The label's text
            text: labelText,
            // The font to use
            fnt: smallFont,
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            // The text's colour
            textColor: Font.CR_WHITE
        );
        // Calculate the horizontal position for the label so that it's centered on the screen.
        aLabel.SetPosX (aButton.GetPosX () - smallFont.stringWidth (aLabel.GetText ()));
        // Add the label element to the main frame.
        aLabel.Pack (buttonFrame);

        blocksCount.Push(1);
    }

    override void handleBack() {
		super.handleBack();
        menuactive = Menu.OnNoPause;
	}

    void CreateCategoryBox(string labelText, string commandName, Vector2 baseRes, out array <int> blocksCount, int fontColor, ZDA_ZF_Frame frame) 
    {
        let boxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );
        
        let offsetX = 75;
        // Add a box image.
        let boxSize = (200, 35);
        let boxOffset = offsetX + boxSize.X / 4 * blocksCount.Size();
        let boxInnerOffset = blocksCount.Size() * 10;

        let aBoxImage = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            (offsetX, boxOffset + boxInnerOffset),
            // Size
            boxSize,
            // Texture
            boxTexture,
            // Scale
            (0.25, 0.25)
        );
        // Add the box image element into the main frame.
        aBoxImage.Pack (frame);

        // Create the button's textures.
        let buttonIdle = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonIdle.png", true);
        let buttonHover = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonHovered.png", false);
        let buttonClick = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/ZFormsExamples/SmallButtonClicked.png", false);

        let buttonSideSize = 18;
        let buttonPosX = offsetX + aBoxImage.GetWidth() / 2 - buttonSideSize / 2;
        let buttonPosY = boxOffset + boxInnerOffset + aBoxImage.GetHeight() / 2 - buttonSideSize / 2;
        

        // Add a button.
        aButton = ZDA_ZF_Button.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (offsetX, boxOffset + boxInnerOffset),
            // Size
            boxSize,
            text: labelText,
            // Our command handler
            cmdHandler: handler,
            // A command string for the button
            command: commandName,
            // The button's textures
            //inactive: buttonIdle,
            //hover: buttonHover,
            //click: buttonClick,
            fnt: bigFont,
            textScale: 2,
            textColor: fontColor,
            alignment: ZDA_ZF_Button.AlignType_CenterLeft 
        );
        // Add the button element into the main frame.
        aButton.Pack (frame);

        // Add a label.
        /*aLabel = ZDA_ZF_Label.Create
        (
            // Position
            (offsetX, aButton.GetPosY() - 4),
            // Size.
            (0, bigFont.GetHeight ()),
            // The label's text
            text: labelText,
            // The font to use
            fnt: bigFont,
            
            // Whether to automatically wrap the text or not
            wrap: false,
            // Whether to automatically resize the element based on the text width
            autoSize: true,
            textScale: 2,
            // The text's colour
            textColor: fontColor
        );
        // Calculate the horizontal position for the label so that it's centered on the screen.
        //aLabel.SetPosX (offsetX);
        // Add the label element to the main frame.
        aLabel.Pack (mainFrame);*/

        blocksCount.Push(1);
    }
}

class ZDA_ZF_SkillLabel : ZDA_ZF_Label
{
    ZDRPGSkill Skill;
    name Type;

    static ZDA_ZF_SkillLabel create(
		Vector2 pos, Vector2 size, string text = "", Font fnt = NULL, AlignType alignment = AlignType_TopLeft,
		bool wrap = true, bool autoSize = false, double textScale = 1, int textColor = Font.CR_WHITE,
		double lineSpacing = 0, ZDA_ZF_Element forElement = NULL
	) {
		let ret = new('ZDA_ZF_SkillLabel');

		ret.setBox(pos, size);
		ret.config(text, fnt, alignment, wrap, autoSize, textScale, textColor, lineSpacing, forElement);

		return ret;
	}

    override void drawer() {
		super.drawer();
        if(Skill)
        {
            switch(Type)
            {
                case 'EP':
                    self.SetText("EP: " .. Skill.SkillLevel * Skill.EPCost);
                    break;
                case 'Modules':
                    if(Skill.SkillLevel < Skill.MaxLevel)
                        self.SetText("Modules: " .. Skill.SkillLevel * Skill.ModulesCost);
                    else
                        self.hide();
            }
        }
		    
	}
}

class ZDA_ZF_SkillDescriptionFrame : ZDA_ZF_Frame
{
    ZDRPGSkill Skill;
    ZDA_ZF_Label EPCostLabel;
    ZDA_ZF_Label ModulesCostLabel;
    ZDA_ZF_Label SkillLevelLabel;
    ZDA_ZF_Button UpgradeSkillButton;
    ZDA_ZF_Button UseSkillButton;

    ZDA_ZF_Button IncreaseSkillLevelButton;
    ZDA_ZF_Button DecreaseSkillLevelButton;

    int currentLevelEPCost;
    int nextLevelEPCost;
    string EPCostLabelText;

    string UpgradeSkillButtonText;

    static ZDA_ZF_SkillDescriptionFrame create(Vector2 pos, Vector2 size) {
		let ret = new('ZDA_ZF_SkillDescriptionFrame');

		ret.setBox(pos, size);
		ret.alpha = 1;

		return ret;
	}

    override void drawer() {
		super.drawer();
        if(Skill)
        {
            if(Skill.SkillLevel != Skill.MaxLevel)
            {
                if(ModulesCostLabel.isHidden())
                    ModulesCostLabel.show();
            }
            else
            {
                if(!ModulesCostLabel.isHidden())
                    ModulesCostLabel.hide();
            }

            if(EPCostLabel)
            {
                currentLevelEPCost = Skill.EPCost * (Skill.SelectedSkillLevel > 0 ? Skill.SelectedSkillLevel : 1);

                if(Skill.SkillLevel == 0 || Skill.SkillLevel == Skill.MaxLevel)
                    nextLevelEPCost = 0;
                else
                    nextLevelEPCost = Skill.EPCost;

                EPCostLabelText = "EP: " .. currentLevelEPCost; 
                //EPCostLabel.SetText(EPCostLabelText);
            }
                
            
            if(ModulesCostLabel)
                ModulesCostLabel.SetText("Modules: " .. (Skill.SkillLevel + 1) * Skill.ModulesCost);

            if(SkillLevelLabel)
                SkillLevelLabel.SetText("Level: " .. Skill.SelectedSkillLevel .. " / " .. Skill.MaxLevel);

            if(UpgradeSkillButton)
            {
                if(Skill.SkillLevel == 0)
                {
                    UpgradeSkillButton.SetTextColor(Font.CR_GREEN);
                    UpgradeSkillButtonText = "Learn";
                }
                else if(Skill.SkillLevel == Skill.MaxLevel)
                {
                    UpgradeSkillButtonText = "Max level";
                    UpgradeSkillButton.SetTextColor(Font.CR_GREY);
                }
                else
                {
                    UpgradeSkillButton.SetTextColor(Font.CR_GREEN);
                    UpgradeSkillButtonText = "Upgrade";
                }
                    
                UpgradeSkillButton.SetText(UpgradeSkillButtonText);

                if(UpgradeSkillButton.containsMouse())
                {
                    if(Skill.SkillLevel < Skill.MaxLevel)
                        ModulesCostLabel.show();
                    if(nextLevelEPCost > 0)
                        EPCostLabel.SetText(EPCostLabelText .. " (+" .. nextLevelEPCost .. ")");
                } else 
                {
                    EPCostLabel.SetText(EPCostLabelText);
                    ModulesCostLabel.hide();
                }
            }

            if(UseSkillButton)
            {
                if(Skill.SkillLevel != 0)
                    UseSkillButton.show();
                else
                    UseSkillButton.hide();
            }

            if(IncreaseSkillLevelButton)
            {
                if(Skill.SkillLevel != 0 && Skill.SelectedSkillLevel < Skill.SkillLevel)
                    IncreaseSkillLevelButton.show();
                else
                    IncreaseSkillLevelButton.hide();
            }

            if(DecreaseSkillLevelButton)
            {
                if(Skill.SkillLevel != 0 && Skill.SelectedSkillLevel > 1)
                    DecreaseSkillLevelButton.show();
                else
                    DecreaseSkillLevelButton.hide();
            }
        }
		    
	}
}