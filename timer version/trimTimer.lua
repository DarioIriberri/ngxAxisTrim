-- Mandatory: Set your axis minimum and maximum readouts here:
MIN_AXIS = 16384
MAX_AXIS = -16384

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

-- Set the range for the NGX trim. In the example, -0.20 to 16.90 means full trim range control: 
-- with the axis set to minimum detent, you'll get -0.20º of trim, while maximum axis input will result in 16.90º of trim 
-- 3 to 8 is the "green-zone". You get more precision with a smaller range
--MIN_TRIM = -0.20
--MAX_TRIM = 16.90

MIN_TRIM = -16
MAX_TRIM = 16

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

--Shouldn't be modified
PRECISION = 0.04

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

HALT = -1

function trimSet(param)
	--ipc.log("ap " .. ipc.readUD(0x07BC))
	apOFF = ipc.readUD(0x07BC) == 0
	
	if not(param == nil) and apOFF then
		factor = (MAX_AXIS - MIN_AXIS) / (MAX_TRIM - MIN_TRIM)
		offset = MIN_TRIM - (MIN_AXIS / factor)
		
		trimTarget = (param / factor) + offset
		current = ipc.readSW(0x0BC0) / 1000
		
		ipc.set("trimTarget", trimTarget)
	end
end

function trim(time)
	factor = (MAX_AXIS - MIN_AXIS) / (MAX_TRIM - MIN_TRIM)
	offset = MIN_TRIM - (MIN_AXIS / factor)

	current = ipc.readSW(0x0BC0) / 1000
	target = ipc.get("trimTarget")
	
	--ipc.log("ap " .. ipc.readUD(0x07BC))
	apOFF = ipc.readUD(0x07BC) == 0
	
	if not apOFF then
		ipc.set("trimTarget", HALT)
	else
		if not(target == nil) and not (target == HALT) then
			if target - current > PRECISION then
				ipc.control(65615)
				ipc.sleep(100)
				
				ipc.writeSTR(0x3380, "Trim: Target = " .. format_num(tonumber(target), 2, "") .. " - Current = " .. format_num(tonumber(ipc.readSW(0x0BC0) / 1000), 2, ""));
				ipc.writeSW(0x32FA, 5);
				
				--ipc.set("lastTrimSet", current)
				
			elseif current - target > PRECISION then
				ipc.control(65607)
				ipc.sleep(100)
				
				ipc.writeSTR(0x3380, "Trim: Target = " .. format_num(tonumber(target), 2, "") .. " - Current = " .. format_num(tonumber(ipc.readSW(0x0BC0) / 1000), 2, ""));
				ipc.writeSW(0x32FA, 5);
				
				--ipc.set("lastTrimSet", current)
			end
		end
	end
		
	current = ipc.readSW(0x0BC0) / 1000
end

function format_num(num, idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end

event.param("trimSet")
event.timer(200, "trim")