exports.name = "scholar"
exports.desc = "A scholar bot!"

exports.setup = (telegram, store) ->
	{google} = require './google'

	[
			cmd: 'google'
			desc: 'Google for something'
			num: 1
			act: (msg, sth) ->
				if sth?
					google msg.text, (items) =>
						if !items? or items.lenth == 0
							telegram.sendMessage msg.chat.id, 'Oops, I don\'t know'
						else
							opt = ''
							(opt += "#{item.link}\n#{item.title}\n#{item.desc}\n\n" if item.link?) for item in items
							telegram.sendMessage msg.chat.id, opt
	]
