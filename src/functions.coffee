exports.name = "scholar"
exports.desc = "A scholar bot!"

exports.setup = (telegram, store) ->
	mathjs = require 'mathjs'
	{google} = require './google'

	[
			cmd: 'google'
			desc: 'Google for something, If the query contains spaces, wrap it with quotes (") '
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
		,
			cmd: 'calc'
			args: '<expression>'
			num: -1
			desc: 'Calculate <expression>. For details about expression format, see http://mathjs.org/docs/expressions/syntax.html'
			act: (msg, args) ->
				# First, reconstruct the expression
				exp = ''
				for arg in args
					exp += arg + ' '
				exp = exp.trim()
				console.log exp
				telegram.sendMessage msg.chat.id, mathjs.eval exp

	]
