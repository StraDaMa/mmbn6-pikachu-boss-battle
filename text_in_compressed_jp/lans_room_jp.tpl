@archive lans_room_jp
@size 5

script 0 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	熱斗くん､
	メールを よもうよ!
	"""
	keyWait
		any = false
	end
}

script 1 mmbn6 {
	msgOpen
	"""
	人気ゲームシリーズに
	とうじょうするキャラクターの
	ぬいぐるみのようだ
	"""
	keyWait
		any = false
	clearMsg
	"""
	このぬいぐるみには､ピカチュウの
	バトルイメージデータが
	入っている
	"""
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = MegaMan
	"""
	熱斗くん､ピカチュウに
	ちょうせんする?
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
	"はい "
	option
		brackets = 0
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 1
	"いいえ"
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
	りょうかい､
	また ちょうせんしようね!
	"""
	keyWait
		any = false
	end
}

script 2 mmbn6 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"熱斗くん､オペレートおねがい!"
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = Lan
	"""
	まかせとけ!
	バトルオペレーション､セット!
	"""
	keyWait
		any = false
	clearMsg
	mugshotShow
		mugshot = MegaMan
	"イン!"
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
	・・・やったね!
	"""
	keyWait
		any = false
	clearMsg
	"""
	熱斗くん､
	ナイス オペレーティング!
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
	クッ・・・
	"""
	keyWait
		any = false
	clearMsg
	"""
	つぎは まけないように
	がんばろうね､熱斗くん!
	"""
	keyWait
		any = false
	flagClear
		flag = 0x130F
	end
}