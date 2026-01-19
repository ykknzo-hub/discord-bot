require("dotenv").config();

const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, ModalBuilder, TextInputBuilder, TextInputStyle } = require('discord.js');
const fs = require('fs');
const path = require('path');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

const NAMETAG_FILE = path.join(__dirname, 'nametags.json');
const CONFIG_FILE = path.join(__dirname, 'bot_config.json');

const COLOR_NAMES = {
    'red': [255, 0, 0], 'green': [0, 255, 0], 'blue': [0, 0, 255],
    'yellow': [255, 255, 0], 'orange': [255, 165, 0], 'purple': [128, 0, 128],
    'pink': [255, 192, 203], 'cyan': [0, 255, 255], 'magenta': [255, 0, 255],
    'lime': [0, 255, 0], 'white': [255, 255, 255], 'black': [0, 0, 0],
    'gray': [128, 128, 128], 'grey': [128, 128, 128], 'brown': [165, 42, 42],
    'gold': [255, 215, 0], 'silver': [192, 192, 192], 'navy': [0, 0, 128],
    'teal': [0, 128, 128], 'maroon': [128, 0, 0], 'olive': [128, 128, 0],
    'lightblue': [173, 216, 230], 'darkred': [139, 0, 0], 'darkblue': [0, 0, 139],
    'darkgreen': [0, 100, 0], 'violet': [238, 130, 238], 'indigo': [75, 0, 130],
    'crimson': [220, 20, 60], 'coral': [255, 127, 80], 'lavender': [230, 230, 250],
    'mint': [189, 252, 201], 'peach': [255, 218, 185], 'rose': [255, 0, 127],
    'sky': [135, 206, 235], 'turquoise': [64, 224, 208]
};

function parseColor(input) {
    const normalized = input.toLowerCase().trim();
    if (COLOR_NAMES[normalized]) return COLOR_NAMES[normalized];
    const parts = input.split(',').map(v => parseInt(v.trim()));
    if (parts.length === 3 && parts.every(v => !isNaN(v) && v >= 0 && v <= 255)) return parts;
    return null;
}

let nametags = {};
if (fs.existsSync(NAMETAG_FILE)) {
    nametags = JSON.parse(fs.readFileSync(NAMETAG_FILE, 'utf8'));
}

let config = { token: '', prefix: ':' };
if (fs.existsSync(CONFIG_FILE)) {
    config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
}

function saveNametags() {
    fs.writeFileSync(NAMETAG_FILE, JSON.stringify(nametags, null, 2));
    updateLuaScript();
}

function updateLuaScript() {
    const scriptPath = path.join(__dirname, 'nametags_script.lua');
    if (!fs.existsSync(scriptPath)) return;
    
    let luaScript = fs.readFileSync(scriptPath, 'utf8');
    let customPlayersContent = '';
    
    for (const [username, data] of Object.entries(nametags)) {
        const r = data.color.r || 255;
        const g = data.color.g || 255;
        const b = data.color.b || 255;
        const gr = data.glowColor.r || 255;
        const gg = data.glowColor.g || 255;
        const gb = data.glowColor.b || 255;
        
        customPlayersContent += `    ["${username}"] = {\n`;
        customPlayersContent += `        color = Color3.fromRGB(${r}, ${g}, ${b}),\n`;
        customPlayersContent += `        glowColor = Color3.fromRGB(${gr}, ${gg}, ${gb}),\n`;
        customPlayersContent += `        customName = "${data.customName}"\n`;
        customPlayersContent += `    },\n`;
    }
    
    const regex = /local customPlayers = \{[\s\S]*?\}/;
    const newTable = `local customPlayers = {\n${customPlayersContent}}`;
    luaScript = luaScript.replace(regex, newTable);
    fs.writeFileSync(scriptPath, luaScript);
}

client.on('ready', () => {
    console.log(`✅ Bot logged in as ${client.user.tag}`);
    console.log(`🎮 KIKO Nametag System Ready!`);
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    if (!message.content.startsWith(config.prefix)) return;

    const args = message.content.slice(config.prefix.length).trim().split(/ +/);
    const command = args.shift().toLowerCase();

    if (command === 'createnametag') {
        const embed = new EmbedBuilder()
            .setColor('#5865F2')
            .setTitle('🎨 KIKO Nametag System')
            .setDescription('Choose an option:')
            .setTimestamp()
            .setFooter({ text: 'KIKO Nametag Manager' });

        const row = new ActionRowBuilder()
            .addComponents(
                new ButtonBuilder()
                    .setCustomId('customize_nametag')
                    .setLabel('1. Customize Existing Nametag')
                    .setStyle(ButtonStyle.Primary)
                    .setEmoji('✏️'),
                new ButtonBuilder()
                    .setCustomId('create_nametag')
                    .setLabel('2. Create Nametag')
                    .setStyle(ButtonStyle.Success)
                    .setEmoji('➕'),
                new ButtonBuilder()
                    .setCustomId('remove_nametag')
                    .setLabel('3. Remove Nametag')
                    .setStyle(ButtonStyle.Danger)
                    .setEmoji('🗑️')
            );

        await message.reply({ embeds: [embed], components: [row] });
    }

    if (command === 'listnametags') {
        const nametagList = Object.entries(nametags)
            .map(([username, data]) => `**${username}**: ${data.customName}`)
            .join('\n') || 'No nametags configured yet.';

        const embed = new EmbedBuilder()
            .setColor('#5865F2')
            .setTitle('📋 Current Nametags')
            .setDescription(nametagList)
            .setTimestamp();

        await message.reply({ embeds: [embed] });
    }
});

client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton() && !interaction.isModalSubmit()) return;

    if (interaction.isButton()) {
        if (interaction.customId === 'create_nametag') {
            const modal = new ModalBuilder()
                .setCustomId('create_nametag_modal')
                .setTitle('Create New Nametag');

            const usernameInput = new TextInputBuilder()
                .setCustomId('username')
                .setLabel('Roblox Username or UserID')
                .setStyle(TextInputStyle.Short)
                .setRequired(true)
                .setPlaceholder('e.g., PlayerName or 123456789');

            const customNameInput = new TextInputBuilder()
                .setCustomId('customName')
                .setLabel('Display Name')
                .setStyle(TextInputStyle.Short)
                .setRequired(true)
                .setPlaceholder('e.g., KIKO OWNER');

            const colorInput = new TextInputBuilder()
                .setCustomId('color')
                .setLabel('Color (name or RGB)')
                .setStyle(TextInputStyle.Short)
                .setRequired(true)
                .setPlaceholder('e.g., red, gold, or 255,100,50');

            const glowColorInput = new TextInputBuilder()
                .setCustomId('glowColor')
                .setLabel('Glow Color (name or RGB)')
                .setStyle(TextInputStyle.Short)
                .setRequired(true)
                .setPlaceholder('e.g., blue, purple, or 100,200,255');

            modal.addComponents(
                new ActionRowBuilder().addComponents(usernameInput),
                new ActionRowBuilder().addComponents(customNameInput),
                new ActionRowBuilder().addComponents(colorInput),
                new ActionRowBuilder().addComponents(glowColorInput)
            );

            await interaction.showModal(modal);
        }

        if (interaction.customId === 'customize_nametag') {
            const modal = new ModalBuilder()
                .setCustomId('customize_nametag_modal')
                .setTitle('Customize Existing Nametag');

            const usernameInput = new TextInputBuilder()
                .setCustomId('username')
                .setLabel('Roblox Username or UserID to Customize')
                .setStyle(TextInputStyle.Short)
                .setRequired(true);

            const customNameInput = new TextInputBuilder()
                .setCustomId('customName')
                .setLabel('New Display Name (leave empty to keep)')
                .setStyle(TextInputStyle.Short)
                .setRequired(false);

            const colorInput = new TextInputBuilder()
                .setCustomId('color')
                .setLabel('New Color (leave empty to keep)')
                .setStyle(TextInputStyle.Short)
                .setRequired(false)
                .setPlaceholder('e.g., red, gold, or 255,100,50');

            const glowColorInput = new TextInputBuilder()
                .setCustomId('glowColor')
                .setLabel('New Glow Color (leave empty to keep)')
                .setStyle(TextInputStyle.Short)
                .setRequired(false)
                .setPlaceholder('e.g., blue, purple, or 100,200,255');

            modal.addComponents(
                new ActionRowBuilder().addComponents(usernameInput),
                new ActionRowBuilder().addComponents(customNameInput),
                new ActionRowBuilder().addComponents(colorInput),
                new ActionRowBuilder().addComponents(glowColorInput)
            );

            await interaction.showModal(modal);
        }

        if (interaction.customId === 'remove_nametag') {
            const modal = new ModalBuilder()
                .setCustomId('remove_nametag_modal')
                .setTitle('Remove Nametag');

            const usernameInput = new TextInputBuilder()
                .setCustomId('username')
                .setLabel('Roblox Username or UserID to Remove')
                .setStyle(TextInputStyle.Short)
                .setRequired(true);

            modal.addComponents(new ActionRowBuilder().addComponents(usernameInput));
            await interaction.showModal(modal);
        }
    }

    if (interaction.isModalSubmit()) {
        if (interaction.customId === 'create_nametag_modal') {
            const username = interaction.fields.getTextInputValue('username');
            const customName = interaction.fields.getTextInputValue('customName');
            const colorStr = interaction.fields.getTextInputValue('color');
            const glowColorStr = interaction.fields.getTextInputValue('glowColor');

            const colorParts = parseColor(colorStr);
            const glowColorParts = parseColor(glowColorStr);

            if (!colorParts) {
                await interaction.reply({ content: '❌ Invalid color format!', ephemeral: true });
                return;
            }

            if (!glowColorParts) {
                await interaction.reply({ content: '❌ Invalid glow color format!', ephemeral: true });
                return;
            }

            nametags[username] = {
                color: { r: colorParts[0], g: colorParts[1], b: colorParts[2] },
                glowColor: { r: glowColorParts[0], g: glowColorParts[1], b: glowColorParts[2] },
                customName: customName
            };

            saveNametags();

            const embed = new EmbedBuilder()
                .setColor('#00FF00')
                .setTitle('✅ Nametag Created!')
                .addFields(
                    { name: 'Username', value: username, inline: true },
                    { name: 'Display Name', value: customName, inline: true },
                    { name: 'Color', value: `RGB(${colorParts.join(', ')})`, inline: true },
                    { name: 'Glow Color', value: `RGB(${glowColorParts.join(', ')})`, inline: true }
                )
                .setTimestamp();

            await interaction.reply({ embeds: [embed] });
        }

        if (interaction.customId === 'customize_nametag_modal') {
            const username = interaction.fields.getTextInputValue('username');
            
            if (!nametags[username]) {
                await interaction.reply({ content: `❌ No nametag found for ${username}`, ephemeral: true });
                return;
            }

            const customName = interaction.fields.getTextInputValue('customName');
            const colorStr = interaction.fields.getTextInputValue('color');
            const glowColorStr = interaction.fields.getTextInputValue('glowColor');

            if (customName) nametags[username].customName = customName;

            if (colorStr) {
                const colorParts = parseColor(colorStr);
                if (colorParts) {
                    nametags[username].color = { r: colorParts[0], g: colorParts[1], b: colorParts[2] };
                } else {
                    await interaction.reply({ content: '❌ Invalid color format!', ephemeral: true });
                    return;
                }
            }

            if (glowColorStr) {
                const glowColorParts = parseColor(glowColorStr);
                if (glowColorParts) {
                    nametags[username].glowColor = { r: glowColorParts[0], g: glowColorParts[1], b: glowColorParts[2] };
                } else {
                    await interaction.reply({ content: '❌ Invalid glow color format!', ephemeral: true });
                    return;
                }
            }

            saveNametags();

            const embed = new EmbedBuilder()
                .setColor('#FFA500')
                .setTitle('✏️ Nametag Updated!')
                .addFields(
                    { name: 'Username', value: username, inline: true },
                    { name: 'Display Name', value: nametags[username].customName, inline: true }
                )
                .setTimestamp();

            await interaction.reply({ embeds: [embed] });
        }

        if (interaction.customId === 'remove_nametag_modal') {
            const username = interaction.fields.getTextInputValue('username');

            if (!nametags[username]) {
                await interaction.reply({ content: `❌ No nametag found for ${username}`, ephemeral: true });
                return;
            }

            delete nametags[username];
            saveNametags();

            const embed = new EmbedBuilder()
                .setColor('#FF0000')
                .setTitle('🗑️ Nametag Removed!')
                .setDescription(`Successfully removed nametag for **${username}**`)
                .setTimestamp();

            await interaction.reply({ embeds: [embed] });
        }
    }
});

if (!config.token) {
    console.log('⚠️  Please add your bot token to bot_config.json');
} else {
    client.login(config.token);
}
