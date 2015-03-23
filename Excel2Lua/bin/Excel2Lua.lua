require "lfs"
require "json"
require "lc"-------这个lc.dll有个bug,ansi转utf-8后 会多出ULL三个字符
print(lc.help())
require "luacom"----这个luacom.dll有bug，程序运行结束会崩掉


local Excel = {}
local function start(path)
	local num = 0
	local curDir = lfs.currentdir();
    for fileName in lfs.dir(path) do
        if fileName ~= "." and fileName ~= ".." then
            if string.find(fileName, ".xlsx") ~= nil then--
                local filePath = curDir.."\\"..path .. "\\" .. fileName
                fileName = string.sub(fileName, 1, string.find(fileName, ".xlsx") - 1)
                Excel.excel2Lua(filePath,fileName,outputName) 
                num = num + 1
                print("change to lua sucessful",filePath,num)
             end
        end
    end
end
local function writeFile(filename,str )
    local f = assert(io.open(filename, 'w'))
    f:write(str)
    f:close()
end


--- 打开Excel文件
-- @param filename excel文件名
function Excel.open(filename)
    local excel = luacom.CreateObject("Excel.Application")
    if not excel then
        return nil, "CreateObject Excel.Application fail"
    end
    assert(luacom.GetType(excel) == "LuaCOM")
    excel.Visible = false--不显示EXCEL窗口
    excel.WorkBooks:Open(filename, nil, isReadOnly)
    return excel
end
 
--- 选择excel文件中的第几张表格
function Excel.selectSheet(excel, sheet)
    return excel.ActiveWorkbook.Sheets(sheet):Select()
end
 
function Excel.close(excel)
    local save = 0
    local alerts = 0
    excel.Application.DisplayAlerts = alerts
    excel.Application.ScreenUpdating = alerts
    excel.Application:Quit()
end
 
function Excel.read(excel, row, column)
    return excel.Activesheet.Cells(row, column).Value2
end
 
function Excel.write(excel, row, column, temp)
    excel.Activesheet.Cells(row, column).Value2 = temp
end
 
 --=============================================================
function Excel.excel2Lua(pathFilename,filename,outputName) 
	local excel = Excel.open(pathFilename);--Excel.open("C:\\Users\\Vincent\\Desktop\\lua-5.3.0\\Json2Lua\\44.xlsx")
	local sheetNum = excel.ActiveWorkbook.Sheets.Count;

	for i=1,sheetNum do
		Excel.excelSheet2Lua(excel,i,excel.ActiveWorkbook.Sheets(i).Name,filename);
	end
	Excel.close(excel)
end
--=============================================================
function Excel.excelSheet2Lua(excel,sheetNum,outputName,filename) 
	Excel.selectSheet(excel, sheetNum)
	local rows = excel.ActiveSheet.UsedRange.Rows.Count --表格的行数
	local columns = excel.ActiveSheet.UsedRange.Columns.Count --表格的列数
	local key = {};
	local KEYNAME = 2;
	local KEYTYPE = 3;
	if not excel or rows < KEYTYPE then
		return;-- sheet没有有效数据
	end
	for j = 1,columns do
		local keyName = Excel.read(excel, KEYNAME, j);
		local keyType = Excel.read(excel, KEYTYPE, j);
		if  keyName and keyType then
			key[keyName] = keyType;
		end
	end
	local str = {};
	local temp = "local a = {\n"
	for i = KEYTYPE+1,rows do
		local mainKey = Excel.read(excel, KEYTYPE, 1);
		if mainKey == "int " then
			temp = temp..string.format("[%s] = {\n",Excel.read(excel, i, 1));
		else
			temp = temp..string.format("[%q] = {\n",Excel.read(excel, i, 1));
		end
	    for j = 1,columns do
	       	local keyName = Excel.read(excel, KEYNAME, j);
			local keyType = Excel.read(excel, KEYTYPE, j);
			if  keyName and keyType then
				local value = Excel.read(excel, i, j) or "\"\"";
							if keyType ~= "str" then
					temp = temp.. string.format("   [%q] = %s,\n",keyName,value);
				else
					temp = temp..string.format("    [%q] = %q,\n",keyName,value);
				end
			end
	    end
	    temp = temp.."   },\n";
	end

	temp = temp.."}\n return a;";
	temp = lc.a2u(temp);---asic 转utf-8
	temp = string.sub(temp,1,string.len(temp)-1);--解决转码带来的bug
	outputName = string.format("./output/%s_%s.lua",filename,outputName);
	writeFile(outputName,temp)
end



---从这里开始
start("\excel")
