exports.name = "scholar"
exports.desc = "A scholar bot!"

exports.setup = (telegram, store, server) ->
	mathjs = require 'mathjs'

	[
			cmd: 'google'
			desc: 'Google for something, If the query contains spaces, wrap it with quotes (") '
			num: 1
			act: (msg, sth) ->
				googleFor sth, msg, 0, telegram, store, server

		,
			cmd: 'calc'
			args: '<expression>'
			num: -1
			desc: 'Calculate <expression>. For details about expression format, see http://mathjs.org/docs/expressions/syntax.html'
			act: (msg, args) ->
				# First, reconstruct the expression
				exp = ''
				exp += arg + ' ' for arg in args
				exp = exp.trim()
				console.log exp

				# Parse all expressions
				parser = mathjs.parser()
				res = ''
				for line in exp.split '\n'
					t = parser.eval line
					res += t + '\n' if t != ''
				telegram.sendMessage msg.chat.id, res, msg.message_id if res != ''

	]

googleFor = (query, msg, start, telegram, store, server) ->
	{google} = require './google'
	pkg = require '../package.json'
	google query, (items, next) =>
		if !items or items.lenth == 0
			server.releaseInput msg.chat.id, msg.from.id
		else
			opt = ''
			# Groups start with '#' connect to IRC. Disable long output.
			if msg.chat.title? and msg.chat.title.startsWith '#'
				# TODO This should be configurable
				opt += "#{items[0].link}\n#{items[0].title}\n#{items[0].desc}"
				opt += '\n\nShowing only the first result in this group.'
			else
				(opt += "#{item.link}\n#{item.title}\n#{item.desc}\n\n" if item.link?) for item in items
				opt += "More results available. Send me 'Next' to see more." if next
			telegram.sendMessage msg.chat.id, opt

			if next and (!msg.chat.title? or !msg.chat.title.startsWith '#')
				server.grabInput msg.chat.id, msg.from.id, pkg.name, 'google'
				store.put 'google', "#{msg.chat.id}next#{msg.from.id}", next, (err) =>
					if err?
						server.releaseInput msg.chat.id, msg.from.id
						telegram.sendMessage msg.chat.id, 'Ooooops, something\'s wrong', start
					else
						store.put 'google', "#{msg.chat.id}query#{msg.from.id}", query, (err) =>
							if err?
								server.releaseInput msg.chat.id, msg.from.id
								telegram.sendMessage msg.chat.id, 'Where is the memory?? #$@#^$%$$'
			else
				server.releaseInput msg.chat.id, msg.from.id
				store.put 'google', "#{msg.chat.id}next#{msg.from.id}", 0
				store.put 'google', "#{msg.chat.id}query#{msg.from.id}", ''
	, start

exports.input = (cmd, msg, telegram, store, server) ->
	switch cmd
		when 'google' then doGoogle msg, telegram, store, server if msg.text.toLowerCase() is 'next'
		else server.releaseInput msg.chat.id, msg.from.id

doGoogle = (msg, telegram, store, server) ->
	console.log "Google!"
	store.get 'google', "#{msg.chat.id}next#{msg.from.id}", (err, next) =>
		if next <= 0
			server.releaseInput msg.chat.id, msg.from.id
		else
			store.get 'google', "#{msg.chat.id}query#{msg.from.id}", (err, query) =>
				if err? or !query? or query == ''
					server.releaseInput msg.chat.id, msg.from.id
					telegram.sendMessage msg.chat.id, 'Oops, I forgot what I should do'
				else
					googleFor query, msg, next, telegram, store, server
