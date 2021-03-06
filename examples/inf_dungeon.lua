package.path = package.path .. ';../?.lua'
local machine = require 'statemachine'

local fsm = machine.create({
	initial = 'room1',

	events = {
		{ name = 'go', from = 'room1', to = 'room2' },
		{ name = 'go', from = 'room2', to = 'room3' },
		{ name = 'go', from = 'room3', to = 'room1' },
	},
	callbacks = {
		on_room1 = function(self) print("Room1"); return self:go() end,
		on_room2 = function(self) print("Room2"); return self:go() end,
		on_room3 = function(self) print("Room3"); return self:go() end,
	}
})

fsm:go()
