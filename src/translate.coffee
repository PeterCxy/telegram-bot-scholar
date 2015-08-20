# Yandex translate
# You must get a Yandex translate API key first.
request = require 'request'
{korubaku} = require 'korubaku'

exports.translate = (telegram, apiKey, text, dest, chat, replyTo) ->
	korubaku (ko) =>
		opts =
			url: 'https://translate.yandex.net/api/v1.5/tr.json/translate'
			formData:
				key: apiKey
				lang: dest
				text: text

		[err, _, body] = yield request.post opts, ko.raw()

		if !err?
			result = JSON.parse body
			if result.code is 200 and result.text? and result.text.length > 0
				telegram.sendMessage chat, result.text[0], replyTo
			else
				telegram.sendMessage chat, '#@RF$%Greg65h56#@@43', replyTo
