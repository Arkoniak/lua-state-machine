package.path = package.path .. ';../?.lua'
local machine = require('statemachine')

local fsm = machine.create({
--	initial = 'logo',
	events = {
		{ name = 'startup', from = 'none', to = 'logo' },
		{ name = 'enter_menu', from = 'logo', to = 'menu' },
		{ name = 'battle_start', from = 'menu', to = 'new_battle' },
		{ name = 'highscore', from = 'menu', to = 'highscore' },
		{ name = 'back_to_menu', from = {'highscore', 'end_battle'}, to = 'menu' },
		{ name = 'ready', from = 'new_battle', to = 'turn_start' },
		{ name = 'start_turn', from = 'turn_start', to = 'movement_phase'},
		{ name = 'move', from = 'movement_phase', to = 'movement_phase' },
		{ name = 'end_move', from = 'movement_phase', to = 'attack_phase' }, -- animation!
		{ name = 'attack', from = 'attack_phase', to = 'attack_phase' },
		{ name = 'end_attack', from = 'attack_phase', to = 'turn_end'}, -- animation!
		{ name = 'battle_over', from = 'turn_end', to = 'end_battle' },
		{ name = 'next_turn', from = 'turn_end', to = 'turn_start'}
	}
})

-- fsm:todot("battle.dot")
local ships
local active_ships
local turn_counter
local games = 50000
local best_result = 0

math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)))

function fsm:on_logo(event, from, to)
	print("Logo -> Menu")
	return fsm:enter_menu()
end

function fsm:on_menu(event, from, to)
	if games > 0 then
		games = games - 1
		print("Menu -> New Battle")
		return fsm:battle_start()
	else
		print("---------------------")
		print("I do not want to play anymore!!!")
		print("My best result is: " .. best_result)
	end
end

function fsm:on_new_battle(event, from, to)
	print("New Battle Begins!")
	ships = 10
	turn_counter = 0
	return fsm:ready()
end

function fsm:on_turn_start(event, from, to)
	turn_counter = turn_counter + 1
	print("  Turn: " .. turn_counter)
	print("  Available Ships: " .. ships)
	active_ships = ships
	return fsm:start_turn()
end

function fsm:on_end_move(event, from, to)
	active_ships = ships
	print("  Attack Phase: ")
end

function fsm:on_movement_phase(event, from, to)
	print("    Active ships: " .. active_ships)
	if active_ships == 0 then 
		return fsm:end_move()
	else
		active_ships = active_ships - 1
		return fsm:move()
	end
end

function fsm:on_end_attack(event, from, to)
	print("  End Turn")
end

function fsm:on_attack_phase(event, from, to)
	if active_ships == 0 then
		return fsm:end_attack()
	else
		res = math.random(2) -- 1 = dead, 2 = survive
		if res == 1 then ships = ships - 1 end
		active_ships = active_ships - 1
		return fsm:attack()
	end
end

function fsm:on_turn_end(event, from, to)
	if ships == 0 then
		return fsm:battle_over()
	else
		return fsm:next_turn()
	end
end

function fsm:on_end_battle(event, from, to)
	print("You have been able to last for " .. turn_counter .. " turns.")
	best_result = math.max(best_result, turn_counter)
	return fsm:back_to_menu()
end

fsm:startup()
