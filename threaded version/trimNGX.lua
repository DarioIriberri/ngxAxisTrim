-- Set your axis minimum and maximum readouts here:
MIN_AXIS = 16384
MAX_AXIS = -16384

-- Set the range for the NGX trim. In the example, -0.20 to 16.90 means full trim range control: 
-- with the axis set to minimum detent, you'll get -0.20º of trim, while maximum axis input will result in 16.90º of trim 
-- 3 to 8 is the "green-zone". You get more precision with a smaller range

--MIN_TRIM = -0.20
--MAX_TRIM = 16.90

MIN_TRIM = 3
MAX_TRIM = 8

-- Set DISPLAY = 1 to enable the on-screen display of the trim value in the format: "Trim: [target value] - [current value]"
-- Set DISPLAY = 0 to disable the on-screen display
DISPLAY = 1

function trimSet(param)
	--ipc.log("trimSet" .. " " .. param)
	factor = (MAX_AXIS - MIN_AXIS) / (MAX_TRIM - MIN_TRIM)
	offset = MIN_TRIM - (MIN_AXIS / factor)
	
	trimTarget = (param / factor) + offset
	
	ipc.set("trimTarget", trimTarget)
		
	ipc.runlua("trimNGXthread", DISPLAY)
end

event.param("trimSet")