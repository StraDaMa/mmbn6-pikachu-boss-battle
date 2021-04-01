@archive lans_room
@size 5

script 0 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"Lan,read your mail!"
	keyWait
		any = false
	end
}

script 1 mmbn6 {
	msgOpen
	"""
	A stuffed toy of a
	character from a popular
	video game series.
	"""
	keyWait
		any = false
	clearMsg
	"""
	It contains battle image
	data for "Pikachu".
	"""
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = MegaMan
	"""
	Lan,are we gonna
	challenge Pikachu?
	"""
	"\n"
	positionOptionHorizontal
		width = 8
	option
		brackets = 0
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 1
	" Yes "
	option
		brackets = 0
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 1
	" No"
	select
		default = 0
		BSeparate = false
		disableB = false
		clear = true
		targets = [
			jump = 2,
			jump = continue,
			jump = continue
		]
	"""
	Roger,let's challenge
	him another time!
	"""
	keyWait
		any = false
	end
}

script 2 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"Go for it,Lan!"
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = Lan
	"""
	Leave it to me!
	Battle routine,set!
	"""
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = MegaMan
	"Execute!"
	keyWait
		any = false
	flagSet
		flag = 0x130F
	end
}

script 3 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	We did it!
	"""
	keyWait
		any = false
	clearMsg
	"""
	Nice work,
	Lan!
	"""
	keyWait
		any = false
	flagClear
		flag = 0x130F
	end
}

script 4 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Dang it...
	"""
	keyWait
		any = false
	clearMsg
	"""
	Let's try harder
	next time,OK,Lan?!
	"""
	keyWait
		any = false
	flagClear
		flag = 0x130F
	end
}