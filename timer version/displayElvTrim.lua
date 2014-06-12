function format_num(num, idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end

trim = ipc.readSW(0x0BC0) / 1000
	
ipc.writeSTR(0x3380, "Trim = " .. format_num(tonumber(trim), 2, ""));
ipc.writeSW(0x32FA, 5);
