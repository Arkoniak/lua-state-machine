function room1()
	print("Room1")
	return room2()
end

function room2()
	print("Room2")
	return room3()
end

function room3()
	print("Room3")
	return room1()
end

room1()
