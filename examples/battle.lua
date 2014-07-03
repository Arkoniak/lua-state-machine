package.path = package.path .. ';../?.lua'
local machine = require('statemachine')

local fsm = machine.create({
--	initial = 'logo',
	events = {
		{ name = 'startup', from = 'none', to = 'logo' },
		{ name = 'enter_menu', from = 'logo', to = 'menu' },
		{ name = 'battle_start', from = 'menu', to = 'new_battle' },
		{ name = 'go_highscore', from = 'menu', to = 'highscore' },
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

math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)))

function fsm:on_logo(event, from, to, options)
	print("Logo -> Menu")
	return fsm:enter_menu(options)
end

function fsm:on_menu(event, from, to, options)
	if options.games > 0 then
		options.best_result = options.best_result or 0
		options.games = options.games - 1
		print("Menu -> New Battle")
		return fsm:battle_start(options)
	elseif options.highscore_visits > 0 then
		print("Menu -> Highscore")
		options.highscore_visits = options.highscore_visits - 1
		return fsm:go_highscore(options)
	else
		print("   ")
		print("I do not want to play anymore!!!")
	end
end

function fsm:on_highscore(event, from, to, options)
	print("+++++++++++++++++++++")
	print("My best result is: " .. options.best_result)
	print("+++++++++++++++++++++")

	return fsm:back_to_menu(options)
end

function fsm:on_new_battle(event, from, to, options)
	print("New Battle Begins!")
	options.ships = 10
	options.turn_counter = 0
	options.moves = 0
--	ships = 10
--	turn_counter = 0
--	moves = 0
	return fsm:ready(options)
end

function fsm:on_turn_start(event, from, to, options)
	options.turn_counter = options.turn_counter + 1
	print("  Turn: " .. options.turn_counter)
	print("  Available Ships: " .. options.ships)
	options.active_ships = options.ships
	options.delta_score = 0
	return fsm:start_turn(options)
end

function fsm:on_end_move(event, from, to, options)
	options.active_ships = options.ships
	print("    Score earned: " .. options.delta_score)
	print("    Current score: " .. options.moves)
	print("  Attack Phase: ")
end

function fsm:on_movement_phase(event, from, to, options)
	if options.active_ships == 0 then 
		return fsm:end_move(options)
	else
		options.delta_score = options.delta_score + 1
		options.moves = options.moves + 1
		options.active_ships = options.active_ships - 1
		return fsm:move(options)
	end
end

function fsm:on_end_attack(event, from, to, options)
	print("    Ships survived: " .. options.ships)
	print("  End Turn")
end

function fsm:on_attack_phase(event, from, to, options)
	if options.active_ships == 0 then
		return fsm:end_attack(options)
	else
		local res = math.random(2) -- 1 = dead, 2 = survive
		if res == 1 then options.ships = options.ships - 1 end
		options.active_ships = options.active_ships - 1
		return fsm:attack(options)
	end
end

function fsm:on_turn_end(event, from, to, options)
	if options.ships == 0 then
		return fsm:battle_over(options)
	else
		return fsm:next_turn(options)
	end
end

function fsm:on_end_battle(event, from, to, options)
	print("You survived for " .. options.turn_counter .. " turns. Your score is " .. options.moves)
	options.best_result = math.max(options.best_result, options.moves)
	return fsm:back_to_menu(options)
end

--fsm:todot("battle.dot")

local options = { games = 100, highscore_visits = 1 }
fsm:startup(options)
