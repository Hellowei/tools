require "lfs"
require "json"

local num = 0
local luaTable = ""

local function readFile(path)
    local f = assert(io.open(path, 'r'))
    local string = f:read("*all")
    f:close()
    return string
end

local function writeFile(path, str)
    local f = assert(io.open(path, 'w'))
    f:write(str)
    f:close()
end


function table_to_string (tt, indent)
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        local keyNum = 0;
        for key, value in pairs (tt) do
            keyNum = keyNum + 1;
        end
        local i = 0;

        for key, value in pairs (tt) do
            i = i + 1;
            if key ~= "__index" then
                table.insert(sb, string.rep ("  ", indent))
                if type (value) == "table" then-----------------------------閸忓啰绀屾稉楦裤€?
                    if type(key) == "number" then
                        table.insert(sb, "["..key.."]" .." = {\n");
                    else
                        table.insert(sb, "[\""..key.."\"]" .." = {\n");
                    end
                    table.insert(sb, table_to_string (value, indent + 2))
                    table.insert(sb, string.rep (" ", indent))
                    table.insert(sb, "},\n");
                elseif "number" == type(value) then----------------閸忓啰绀屾稉鐑樻殶閸婅偐琚?
                        if type(key) == "number" then
                            table.insert(sb, string.format("[%0.0f] = ",key)..value..",\n")
                        else
                            table.insert(sb, string.format("[%s] = ",string.format("%q",tostring (key)))..value..",\n")
                        end
                elseif "string" == type(value) then------------------------------------------閸忓啰绀屾稉鍝勭摟缁楋缚瑕?
                    --if i ~= keyNum then
                        if type(key) == "number" then
                            table.insert(sb, string.format("[%0.0f] = \"%s\",\n",key, tostring(value)))
                        else
                            table.insert(sb, string.format("[%s] = \"%s\",\n",string.format("%q",tostring (key)), tostring(value)))
                        end
                else----------------------------------------------------------------------閸忓啰绀屾稉绡祇olean  function 缁?
                    if type(key) == "number" then
                        table.insert(sb, string.format("[%0.0f] = %s,\n",key, tostring(value)))
                    else
                        table.insert(sb, string.format("[%s] = %s,\n",string.format("%q",tostring (key)), tostring(value)))
                    end
                end
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end


local function convert(jsonName, jsonPath)
    local jsonStr = readFile(jsonPath)
    local tab = json.decode(jsonStr)----閸掆晝鏁ua閼奉亜鐢幒銉ュ經閹跺son閺傚洣娆㈡潪顑胯礋lua闁插瞼娈憈able
    local str = table_to_string(tab);---table鏉烆兛璐熺€涙顑佹稉?
    str = string.format("local %s = {\n",jsonName)..str.."}\n return "..jsonName;
    local outputName = "./output/"..jsonName..".lua";
    writeFile(outputName, str)
end

local function start(path)
    for fileName in lfs.dir(path) do
        if fileName ~= "." and fileName ~= ".." then--閻╊喖缍?
            if string.find(fileName, ".json") ~= nil then--鐠囥儲鏋冩禒鑸垫Цjson閸氬海绱?
                local filePath = path .. '/' .. fileName
                fileName = string.sub(fileName, 1, string.find(fileName, ".json") - 1)
                convert(fileName, filePath)
                num = num + 1
                print(string.format("%s changto lua sucess",fileName));
            end
        end
    end

end

start("./json")

